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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        49
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: iconst_2
          13: anewarray     #2                  // class java/lang/Object
          16: astore_1
          17: aload_1
          18: iconst_0
          19: ldc           #10                 // String Out_of_memory
          21: aastore
          22: aload_1
          23: iconst_1
          24: iconst_m1
          25: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          28: aastore
          29: new           #18                 // class Block
          32: dup
          33: sipush        248
          36: aload_1
          37: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          40: aastore
          41: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          44: iconst_1
          45: iconst_2
          46: anewarray     #2                  // class java/lang/Object
          49: astore_1
          50: aload_1
          51: iconst_0
          52: ldc           #24                 // String Sys_error
          54: aastore
          55: aload_1
          56: iconst_1
          57: bipush        -2
          59: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          62: aastore
          63: new           #18                 // class Block
          66: dup
          67: sipush        248
          70: aload_1
          71: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          74: aastore
          75: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          78: iconst_2
          79: iconst_2
          80: anewarray     #2                  // class java/lang/Object
          83: astore_1
          84: aload_1
          85: iconst_0
          86: ldc           #26                 // String Failure
          88: aastore
          89: aload_1
          90: iconst_1
          91: bipush        -3
          93: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          96: aastore
          97: new           #18                 // class Block
         100: dup
         101: sipush        248
         104: aload_1
         105: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         108: aastore
         109: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         112: iconst_3
         113: iconst_2
         114: anewarray     #2                  // class java/lang/Object
         117: astore_1
         118: aload_1
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: aload_1
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: new           #18                 // class Block
         134: dup
         135: sipush        248
         138: aload_1
         139: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         142: aastore
         143: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         146: iconst_4
         147: iconst_2
         148: anewarray     #2                  // class java/lang/Object
         151: astore_1
         152: aload_1
         153: iconst_0
         154: ldc           #30                 // String End_of_file
         156: aastore
         157: aload_1
         158: iconst_1
         159: bipush        -5
         161: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: new           #18                 // class Block
         168: dup
         169: sipush        248
         172: aload_1
         173: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         176: aastore
         177: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         180: iconst_5
         181: iconst_2
         182: anewarray     #2                  // class java/lang/Object
         185: astore_1
         186: aload_1
         187: iconst_0
         188: ldc           #32                 // String Division_by_zero
         190: aastore
         191: aload_1
         192: iconst_1
         193: bipush        -6
         195: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         198: aastore
         199: new           #18                 // class Block
         202: dup
         203: sipush        248
         206: aload_1
         207: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         210: aastore
         211: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         214: bipush        6
         216: iconst_2
         217: anewarray     #2                  // class java/lang/Object
         220: astore_1
         221: aload_1
         222: iconst_0
         223: ldc           #34                 // String Not_found
         225: aastore
         226: aload_1
         227: iconst_1
         228: bipush        -7
         230: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         233: aastore
         234: new           #18                 // class Block
         237: dup
         238: sipush        248
         241: aload_1
         242: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         245: aastore
         246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         249: bipush        7
         251: iconst_2
         252: anewarray     #2                  // class java/lang/Object
         255: astore_1
         256: aload_1
         257: iconst_0
         258: ldc           #36                 // String Match_failure
         260: aastore
         261: aload_1
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: new           #18                 // class Block
         272: dup
         273: sipush        248
         276: aload_1
         277: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         280: aastore
         281: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         284: bipush        8
         286: iconst_2
         287: anewarray     #2                  // class java/lang/Object
         290: astore_1
         291: aload_1
         292: iconst_0
         293: ldc           #38                 // String Stack_overflow
         295: aastore
         296: aload_1
         297: iconst_1
         298: bipush        -9
         300: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         303: aastore
         304: new           #18                 // class Block
         307: dup
         308: sipush        248
         311: aload_1
         312: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         315: aastore
         316: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         319: bipush        9
         321: iconst_2
         322: anewarray     #2                  // class java/lang/Object
         325: astore_1
         326: aload_1
         327: iconst_0
         328: ldc           #40                 // String Sys_blocked_io
         330: aastore
         331: aload_1
         332: iconst_1
         333: bipush        -10
         335: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         338: aastore
         339: new           #18                 // class Block
         342: dup
         343: sipush        248
         346: aload_1
         347: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         350: aastore
         351: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         354: bipush        10
         356: iconst_2
         357: anewarray     #2                  // class java/lang/Object
         360: astore_1
         361: aload_1
         362: iconst_0
         363: ldc           #42                 // String Assert_failure
         365: aastore
         366: aload_1
         367: iconst_1
         368: bipush        -11
         370: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         373: aastore
         374: new           #18                 // class Block
         377: dup
         378: sipush        248
         381: aload_1
         382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         385: aastore
         386: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         389: bipush        11
         391: iconst_2
         392: anewarray     #2                  // class java/lang/Object
         395: astore_1
         396: aload_1
         397: iconst_0
         398: ldc           #44                 // String Undefined_recursive_module
         400: aastore
         401: aload_1
         402: iconst_1
         403: bipush        -12
         405: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         408: aastore
         409: new           #18                 // class Block
         412: dup
         413: sipush        248
         416: aload_1
         417: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         420: aastore
         421: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         424: bipush        13
         426: ldc           #46                 // String %,
         428: aastore
         429: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         432: bipush        14
         434: ldc           #48                 // String really_input
         436: aastore
         437: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc           #50                 // String input
         444: aastore
         445: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         448: bipush        16
         450: iconst_2
         451: anewarray     #2                  // class java/lang/Object
         454: astore_1
         455: aload_1
         456: iconst_0
         457: iconst_0
         458: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         461: aastore
         462: aload_1
         463: iconst_1
         464: iconst_2
         465: anewarray     #2                  // class java/lang/Object
         468: astore_2
         469: aload_2
         470: iconst_0
         471: bipush        6
         473: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         476: aastore
         477: aload_2
         478: iconst_1
         479: iconst_0
         480: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         483: aastore
         484: new           #18                 // class Block
         487: dup
         488: iconst_0
         489: aload_2
         490: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         493: aastore
         494: new           #18                 // class Block
         497: dup
         498: iconst_0
         499: aload_1
         500: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         503: aastore
         504: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         507: bipush        17
         509: iconst_2
         510: anewarray     #2                  // class java/lang/Object
         513: astore_1
         514: aload_1
         515: iconst_0
         516: iconst_0
         517: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         520: aastore
         521: aload_1
         522: iconst_1
         523: iconst_2
         524: anewarray     #2                  // class java/lang/Object
         527: astore_2
         528: aload_2
         529: iconst_0
         530: bipush        7
         532: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         535: aastore
         536: aload_2
         537: iconst_1
         538: iconst_0
         539: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         542: aastore
         543: new           #18                 // class Block
         546: dup
         547: iconst_0
         548: aload_2
         549: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         552: aastore
         553: new           #18                 // class Block
         556: dup
         557: iconst_0
         558: aload_1
         559: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         562: aastore
         563: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         566: bipush        18
         568: ldc           #52                 // String output_substring
         570: aastore
         571: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        19
         576: ldc           #54                 // String output
         578: aastore
         579: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         582: bipush        20
         584: iconst_2
         585: anewarray     #2                  // class java/lang/Object
         588: astore_1
         589: aload_1
         590: iconst_0
         591: iconst_1
         592: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: aload_1
         597: iconst_1
         598: iconst_2
         599: anewarray     #2                  // class java/lang/Object
         602: astore_2
         603: aload_2
         604: iconst_0
         605: iconst_3
         606: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         609: aastore
         610: aload_2
         611: iconst_1
         612: iconst_2
         613: anewarray     #2                  // class java/lang/Object
         616: astore_3
         617: aload_3
         618: iconst_0
         619: iconst_4
         620: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         623: aastore
         624: aload_3
         625: iconst_1
         626: iconst_2
         627: anewarray     #2                  // class java/lang/Object
         630: astore        4
         632: aload         4
         634: iconst_0
         635: bipush        6
         637: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         640: aastore
         641: aload         4
         643: iconst_1
         644: iconst_0
         645: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         648: aastore
         649: new           #18                 // class Block
         652: dup
         653: iconst_0
         654: aload         4
         656: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         659: aastore
         660: new           #18                 // class Block
         663: dup
         664: iconst_0
         665: aload_3
         666: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         669: aastore
         670: new           #18                 // class Block
         673: dup
         674: iconst_0
         675: aload_2
         676: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         679: aastore
         680: new           #18                 // class Block
         683: dup
         684: iconst_0
         685: aload_1
         686: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: iconst_2
         696: anewarray     #2                  // class java/lang/Object
         699: astore_1
         700: aload_1
         701: iconst_0
         702: iconst_1
         703: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         706: aastore
         707: aload_1
         708: iconst_1
         709: iconst_2
         710: anewarray     #2                  // class java/lang/Object
         713: astore_2
         714: aload_2
         715: iconst_0
         716: iconst_3
         717: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         720: aastore
         721: aload_2
         722: iconst_1
         723: iconst_2
         724: anewarray     #2                  // class java/lang/Object
         727: astore_3
         728: aload_3
         729: iconst_0
         730: iconst_4
         731: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         734: aastore
         735: aload_3
         736: iconst_1
         737: iconst_2
         738: anewarray     #2                  // class java/lang/Object
         741: astore        4
         743: aload         4
         745: iconst_0
         746: bipush        7
         748: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         751: aastore
         752: aload         4
         754: iconst_1
         755: iconst_0
         756: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         759: aastore
         760: new           #18                 // class Block
         763: dup
         764: iconst_0
         765: aload         4
         767: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         770: aastore
         771: new           #18                 // class Block
         774: dup
         775: iconst_0
         776: aload_3
         777: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: new           #18                 // class Block
         784: dup
         785: iconst_0
         786: aload_2
         787: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         790: aastore
         791: new           #18                 // class Block
         794: dup
         795: iconst_0
         796: aload_1
         797: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         800: aastore
         801: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        22
         806: ldc           #56                 // String %.12g
         808: aastore
         809: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        23
         814: ldc           #58                 // String .
         816: aastore
         817: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        24
         822: ldc           #60                 // String %d
         824: aastore
         825: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         828: bipush        25
         830: ldc           #62                 // String false
         832: aastore
         833: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         836: bipush        26
         838: ldc           #64                 // String true
         840: aastore
         841: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         844: bipush        27
         846: iconst_1
         847: anewarray     #2                  // class java/lang/Object
         850: astore_1
         851: aload_1
         852: iconst_0
         853: iconst_1
         854: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         857: aastore
         858: new           #18                 // class Block
         861: dup
         862: iconst_0
         863: aload_1
         864: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         867: aastore
         868: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         871: bipush        28
         873: iconst_1
         874: anewarray     #2                  // class java/lang/Object
         877: astore_1
         878: aload_1
         879: iconst_0
         880: iconst_0
         881: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         884: aastore
         885: new           #18                 // class Block
         888: dup
         889: iconst_0
         890: aload_1
         891: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         894: aastore
         895: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        29
         900: ldc           #62                 // String false
         902: aastore
         903: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        30
         908: ldc           #64                 // String true
         910: aastore
         911: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        31
         916: ldc           #66                 // String bool_of_string
         918: aastore
         919: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        32
         924: ldc           #64                 // String true
         926: aastore
         927: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        33
         932: ldc           #62                 // String false
         934: aastore
         935: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        34
         940: ldc           #68                 // String char_of_int
         942: aastore
         943: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        35
         948: ldc           #70                 // String index out of bounds
         950: aastore
         951: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        36
         956: ldc           #72                 // String Pervasives.array_bound_error
         958: aastore
         959: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         962: bipush        37
         964: ldc           #74                 // String Stdlib.Exit
         966: aastore
         967: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         970: bipush        44
         972: ldc           #76                 // String Pervasives.do_at_exit
         974: aastore
         975: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        46
         980: ldc           #78                 // String hi
         982: aastore
         983: ldc           #78                 // String hi
         985: getstatic     #84                 // Field java/lang/System.out:Ljava/io/PrintStream;
         988: swap
         989: invokevirtual #90                 // Method java/io/PrintStream.println:(Ljava/lang/String;)V
         992: iconst_0
         993: dup
         994: istore_1
         995: return
    }
    |}]

let%expect_test "emission: arithmetic ops" =
  compile_and_javap
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int ((3 * 4) - (10 / 2) + (9 mod 4)) |};
  [%expect {|
    public class Main {
      public static java.lang.Object[] GLOBALS;

      public static void main(java.lang.String[]);
        Code:
           0: bipush        48
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: iconst_2
          13: anewarray     #2                  // class java/lang/Object
          16: astore_1
          17: aload_1
          18: iconst_0
          19: ldc           #10                 // String Out_of_memory
          21: aastore
          22: aload_1
          23: iconst_1
          24: iconst_m1
          25: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          28: aastore
          29: new           #18                 // class Block
          32: dup
          33: sipush        248
          36: aload_1
          37: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          40: aastore
          41: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          44: iconst_1
          45: iconst_2
          46: anewarray     #2                  // class java/lang/Object
          49: astore_1
          50: aload_1
          51: iconst_0
          52: ldc           #24                 // String Sys_error
          54: aastore
          55: aload_1
          56: iconst_1
          57: bipush        -2
          59: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          62: aastore
          63: new           #18                 // class Block
          66: dup
          67: sipush        248
          70: aload_1
          71: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          74: aastore
          75: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          78: iconst_2
          79: iconst_2
          80: anewarray     #2                  // class java/lang/Object
          83: astore_1
          84: aload_1
          85: iconst_0
          86: ldc           #26                 // String Failure
          88: aastore
          89: aload_1
          90: iconst_1
          91: bipush        -3
          93: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          96: aastore
          97: new           #18                 // class Block
         100: dup
         101: sipush        248
         104: aload_1
         105: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         108: aastore
         109: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         112: iconst_3
         113: iconst_2
         114: anewarray     #2                  // class java/lang/Object
         117: astore_1
         118: aload_1
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: aload_1
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: new           #18                 // class Block
         134: dup
         135: sipush        248
         138: aload_1
         139: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         142: aastore
         143: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         146: iconst_4
         147: iconst_2
         148: anewarray     #2                  // class java/lang/Object
         151: astore_1
         152: aload_1
         153: iconst_0
         154: ldc           #30                 // String End_of_file
         156: aastore
         157: aload_1
         158: iconst_1
         159: bipush        -5
         161: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: new           #18                 // class Block
         168: dup
         169: sipush        248
         172: aload_1
         173: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         176: aastore
         177: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         180: iconst_5
         181: iconst_2
         182: anewarray     #2                  // class java/lang/Object
         185: astore_1
         186: aload_1
         187: iconst_0
         188: ldc           #32                 // String Division_by_zero
         190: aastore
         191: aload_1
         192: iconst_1
         193: bipush        -6
         195: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         198: aastore
         199: new           #18                 // class Block
         202: dup
         203: sipush        248
         206: aload_1
         207: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         210: aastore
         211: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         214: bipush        6
         216: iconst_2
         217: anewarray     #2                  // class java/lang/Object
         220: astore_1
         221: aload_1
         222: iconst_0
         223: ldc           #34                 // String Not_found
         225: aastore
         226: aload_1
         227: iconst_1
         228: bipush        -7
         230: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         233: aastore
         234: new           #18                 // class Block
         237: dup
         238: sipush        248
         241: aload_1
         242: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         245: aastore
         246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         249: bipush        7
         251: iconst_2
         252: anewarray     #2                  // class java/lang/Object
         255: astore_1
         256: aload_1
         257: iconst_0
         258: ldc           #36                 // String Match_failure
         260: aastore
         261: aload_1
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: new           #18                 // class Block
         272: dup
         273: sipush        248
         276: aload_1
         277: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         280: aastore
         281: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         284: bipush        8
         286: iconst_2
         287: anewarray     #2                  // class java/lang/Object
         290: astore_1
         291: aload_1
         292: iconst_0
         293: ldc           #38                 // String Stack_overflow
         295: aastore
         296: aload_1
         297: iconst_1
         298: bipush        -9
         300: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         303: aastore
         304: new           #18                 // class Block
         307: dup
         308: sipush        248
         311: aload_1
         312: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         315: aastore
         316: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         319: bipush        9
         321: iconst_2
         322: anewarray     #2                  // class java/lang/Object
         325: astore_1
         326: aload_1
         327: iconst_0
         328: ldc           #40                 // String Sys_blocked_io
         330: aastore
         331: aload_1
         332: iconst_1
         333: bipush        -10
         335: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         338: aastore
         339: new           #18                 // class Block
         342: dup
         343: sipush        248
         346: aload_1
         347: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         350: aastore
         351: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         354: bipush        10
         356: iconst_2
         357: anewarray     #2                  // class java/lang/Object
         360: astore_1
         361: aload_1
         362: iconst_0
         363: ldc           #42                 // String Assert_failure
         365: aastore
         366: aload_1
         367: iconst_1
         368: bipush        -11
         370: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         373: aastore
         374: new           #18                 // class Block
         377: dup
         378: sipush        248
         381: aload_1
         382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         385: aastore
         386: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         389: bipush        11
         391: iconst_2
         392: anewarray     #2                  // class java/lang/Object
         395: astore_1
         396: aload_1
         397: iconst_0
         398: ldc           #44                 // String Undefined_recursive_module
         400: aastore
         401: aload_1
         402: iconst_1
         403: bipush        -12
         405: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         408: aastore
         409: new           #18                 // class Block
         412: dup
         413: sipush        248
         416: aload_1
         417: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         420: aastore
         421: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         424: bipush        13
         426: ldc           #46                 // String %,
         428: aastore
         429: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         432: bipush        14
         434: ldc           #48                 // String really_input
         436: aastore
         437: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc           #50                 // String input
         444: aastore
         445: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         448: bipush        16
         450: iconst_2
         451: anewarray     #2                  // class java/lang/Object
         454: astore_1
         455: aload_1
         456: iconst_0
         457: iconst_0
         458: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         461: aastore
         462: aload_1
         463: iconst_1
         464: iconst_2
         465: anewarray     #2                  // class java/lang/Object
         468: astore_2
         469: aload_2
         470: iconst_0
         471: bipush        6
         473: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         476: aastore
         477: aload_2
         478: iconst_1
         479: iconst_0
         480: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         483: aastore
         484: new           #18                 // class Block
         487: dup
         488: iconst_0
         489: aload_2
         490: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         493: aastore
         494: new           #18                 // class Block
         497: dup
         498: iconst_0
         499: aload_1
         500: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         503: aastore
         504: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         507: bipush        17
         509: iconst_2
         510: anewarray     #2                  // class java/lang/Object
         513: astore_1
         514: aload_1
         515: iconst_0
         516: iconst_0
         517: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         520: aastore
         521: aload_1
         522: iconst_1
         523: iconst_2
         524: anewarray     #2                  // class java/lang/Object
         527: astore_2
         528: aload_2
         529: iconst_0
         530: bipush        7
         532: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         535: aastore
         536: aload_2
         537: iconst_1
         538: iconst_0
         539: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         542: aastore
         543: new           #18                 // class Block
         546: dup
         547: iconst_0
         548: aload_2
         549: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         552: aastore
         553: new           #18                 // class Block
         556: dup
         557: iconst_0
         558: aload_1
         559: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         562: aastore
         563: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         566: bipush        18
         568: ldc           #52                 // String output_substring
         570: aastore
         571: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        19
         576: ldc           #54                 // String output
         578: aastore
         579: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         582: bipush        20
         584: iconst_2
         585: anewarray     #2                  // class java/lang/Object
         588: astore_1
         589: aload_1
         590: iconst_0
         591: iconst_1
         592: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: aload_1
         597: iconst_1
         598: iconst_2
         599: anewarray     #2                  // class java/lang/Object
         602: astore_2
         603: aload_2
         604: iconst_0
         605: iconst_3
         606: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         609: aastore
         610: aload_2
         611: iconst_1
         612: iconst_2
         613: anewarray     #2                  // class java/lang/Object
         616: astore_3
         617: aload_3
         618: iconst_0
         619: iconst_4
         620: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         623: aastore
         624: aload_3
         625: iconst_1
         626: iconst_2
         627: anewarray     #2                  // class java/lang/Object
         630: astore        4
         632: aload         4
         634: iconst_0
         635: bipush        6
         637: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         640: aastore
         641: aload         4
         643: iconst_1
         644: iconst_0
         645: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         648: aastore
         649: new           #18                 // class Block
         652: dup
         653: iconst_0
         654: aload         4
         656: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         659: aastore
         660: new           #18                 // class Block
         663: dup
         664: iconst_0
         665: aload_3
         666: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         669: aastore
         670: new           #18                 // class Block
         673: dup
         674: iconst_0
         675: aload_2
         676: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         679: aastore
         680: new           #18                 // class Block
         683: dup
         684: iconst_0
         685: aload_1
         686: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: iconst_2
         696: anewarray     #2                  // class java/lang/Object
         699: astore_1
         700: aload_1
         701: iconst_0
         702: iconst_1
         703: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         706: aastore
         707: aload_1
         708: iconst_1
         709: iconst_2
         710: anewarray     #2                  // class java/lang/Object
         713: astore_2
         714: aload_2
         715: iconst_0
         716: iconst_3
         717: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         720: aastore
         721: aload_2
         722: iconst_1
         723: iconst_2
         724: anewarray     #2                  // class java/lang/Object
         727: astore_3
         728: aload_3
         729: iconst_0
         730: iconst_4
         731: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         734: aastore
         735: aload_3
         736: iconst_1
         737: iconst_2
         738: anewarray     #2                  // class java/lang/Object
         741: astore        4
         743: aload         4
         745: iconst_0
         746: bipush        7
         748: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         751: aastore
         752: aload         4
         754: iconst_1
         755: iconst_0
         756: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         759: aastore
         760: new           #18                 // class Block
         763: dup
         764: iconst_0
         765: aload         4
         767: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         770: aastore
         771: new           #18                 // class Block
         774: dup
         775: iconst_0
         776: aload_3
         777: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: new           #18                 // class Block
         784: dup
         785: iconst_0
         786: aload_2
         787: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         790: aastore
         791: new           #18                 // class Block
         794: dup
         795: iconst_0
         796: aload_1
         797: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         800: aastore
         801: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        22
         806: ldc           #56                 // String %.12g
         808: aastore
         809: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        23
         814: ldc           #58                 // String .
         816: aastore
         817: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        24
         822: ldc           #60                 // String %d
         824: aastore
         825: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         828: bipush        25
         830: ldc           #62                 // String false
         832: aastore
         833: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         836: bipush        26
         838: ldc           #64                 // String true
         840: aastore
         841: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         844: bipush        27
         846: iconst_1
         847: anewarray     #2                  // class java/lang/Object
         850: astore_1
         851: aload_1
         852: iconst_0
         853: iconst_1
         854: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         857: aastore
         858: new           #18                 // class Block
         861: dup
         862: iconst_0
         863: aload_1
         864: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         867: aastore
         868: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         871: bipush        28
         873: iconst_1
         874: anewarray     #2                  // class java/lang/Object
         877: astore_1
         878: aload_1
         879: iconst_0
         880: iconst_0
         881: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         884: aastore
         885: new           #18                 // class Block
         888: dup
         889: iconst_0
         890: aload_1
         891: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         894: aastore
         895: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        29
         900: ldc           #62                 // String false
         902: aastore
         903: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        30
         908: ldc           #64                 // String true
         910: aastore
         911: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        31
         916: ldc           #66                 // String bool_of_string
         918: aastore
         919: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        32
         924: ldc           #64                 // String true
         926: aastore
         927: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        33
         932: ldc           #62                 // String false
         934: aastore
         935: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        34
         940: ldc           #68                 // String char_of_int
         942: aastore
         943: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        35
         948: ldc           #70                 // String index out of bounds
         950: aastore
         951: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        36
         956: ldc           #72                 // String Pervasives.array_bound_error
         958: aastore
         959: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         962: bipush        37
         964: ldc           #74                 // String Stdlib.Exit
         966: aastore
         967: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         970: bipush        44
         972: ldc           #76                 // String Pervasives.do_at_exit
         974: aastore
         975: iconst_4
         976: dup
         977: istore_1
         978: pop
         979: bipush        9
         981: iload_1
         982: irem
         983: dup
         984: istore_2
         985: pop
         986: iconst_2
         987: dup
         988: istore_3
         989: pop
         990: bipush        10
         992: iload_3
         993: idiv
         994: dup
         995: istore        4
         997: pop
         998: iconst_4
         999: dup
        1000: istore        5
        1002: pop
        1003: iconst_3
        1004: iload         5
        1006: imul
        1007: iload         4
        1009: isub
        1010: iload_2
        1011: iadd
        1012: getstatic     #82                 // Field java/lang/System.out:Ljava/io/PrintStream;
        1015: swap
        1016: invokevirtual #88                 // Method java/io/PrintStream.println:(I)V
        1019: iconst_0
        1020: dup
        1021: istore        6
        1023: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        48
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: iconst_2
          13: anewarray     #2                  // class java/lang/Object
          16: astore_1
          17: aload_1
          18: iconst_0
          19: ldc           #10                 // String Out_of_memory
          21: aastore
          22: aload_1
          23: iconst_1
          24: iconst_m1
          25: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          28: aastore
          29: new           #18                 // class Block
          32: dup
          33: sipush        248
          36: aload_1
          37: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          40: aastore
          41: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          44: iconst_1
          45: iconst_2
          46: anewarray     #2                  // class java/lang/Object
          49: astore_1
          50: aload_1
          51: iconst_0
          52: ldc           #24                 // String Sys_error
          54: aastore
          55: aload_1
          56: iconst_1
          57: bipush        -2
          59: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          62: aastore
          63: new           #18                 // class Block
          66: dup
          67: sipush        248
          70: aload_1
          71: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          74: aastore
          75: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          78: iconst_2
          79: iconst_2
          80: anewarray     #2                  // class java/lang/Object
          83: astore_1
          84: aload_1
          85: iconst_0
          86: ldc           #26                 // String Failure
          88: aastore
          89: aload_1
          90: iconst_1
          91: bipush        -3
          93: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          96: aastore
          97: new           #18                 // class Block
         100: dup
         101: sipush        248
         104: aload_1
         105: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         108: aastore
         109: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         112: iconst_3
         113: iconst_2
         114: anewarray     #2                  // class java/lang/Object
         117: astore_1
         118: aload_1
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: aload_1
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: new           #18                 // class Block
         134: dup
         135: sipush        248
         138: aload_1
         139: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         142: aastore
         143: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         146: iconst_4
         147: iconst_2
         148: anewarray     #2                  // class java/lang/Object
         151: astore_1
         152: aload_1
         153: iconst_0
         154: ldc           #30                 // String End_of_file
         156: aastore
         157: aload_1
         158: iconst_1
         159: bipush        -5
         161: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: new           #18                 // class Block
         168: dup
         169: sipush        248
         172: aload_1
         173: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         176: aastore
         177: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         180: iconst_5
         181: iconst_2
         182: anewarray     #2                  // class java/lang/Object
         185: astore_1
         186: aload_1
         187: iconst_0
         188: ldc           #32                 // String Division_by_zero
         190: aastore
         191: aload_1
         192: iconst_1
         193: bipush        -6
         195: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         198: aastore
         199: new           #18                 // class Block
         202: dup
         203: sipush        248
         206: aload_1
         207: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         210: aastore
         211: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         214: bipush        6
         216: iconst_2
         217: anewarray     #2                  // class java/lang/Object
         220: astore_1
         221: aload_1
         222: iconst_0
         223: ldc           #34                 // String Not_found
         225: aastore
         226: aload_1
         227: iconst_1
         228: bipush        -7
         230: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         233: aastore
         234: new           #18                 // class Block
         237: dup
         238: sipush        248
         241: aload_1
         242: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         245: aastore
         246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         249: bipush        7
         251: iconst_2
         252: anewarray     #2                  // class java/lang/Object
         255: astore_1
         256: aload_1
         257: iconst_0
         258: ldc           #36                 // String Match_failure
         260: aastore
         261: aload_1
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: new           #18                 // class Block
         272: dup
         273: sipush        248
         276: aload_1
         277: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         280: aastore
         281: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         284: bipush        8
         286: iconst_2
         287: anewarray     #2                  // class java/lang/Object
         290: astore_1
         291: aload_1
         292: iconst_0
         293: ldc           #38                 // String Stack_overflow
         295: aastore
         296: aload_1
         297: iconst_1
         298: bipush        -9
         300: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         303: aastore
         304: new           #18                 // class Block
         307: dup
         308: sipush        248
         311: aload_1
         312: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         315: aastore
         316: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         319: bipush        9
         321: iconst_2
         322: anewarray     #2                  // class java/lang/Object
         325: astore_1
         326: aload_1
         327: iconst_0
         328: ldc           #40                 // String Sys_blocked_io
         330: aastore
         331: aload_1
         332: iconst_1
         333: bipush        -10
         335: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         338: aastore
         339: new           #18                 // class Block
         342: dup
         343: sipush        248
         346: aload_1
         347: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         350: aastore
         351: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         354: bipush        10
         356: iconst_2
         357: anewarray     #2                  // class java/lang/Object
         360: astore_1
         361: aload_1
         362: iconst_0
         363: ldc           #42                 // String Assert_failure
         365: aastore
         366: aload_1
         367: iconst_1
         368: bipush        -11
         370: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         373: aastore
         374: new           #18                 // class Block
         377: dup
         378: sipush        248
         381: aload_1
         382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         385: aastore
         386: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         389: bipush        11
         391: iconst_2
         392: anewarray     #2                  // class java/lang/Object
         395: astore_1
         396: aload_1
         397: iconst_0
         398: ldc           #44                 // String Undefined_recursive_module
         400: aastore
         401: aload_1
         402: iconst_1
         403: bipush        -12
         405: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         408: aastore
         409: new           #18                 // class Block
         412: dup
         413: sipush        248
         416: aload_1
         417: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         420: aastore
         421: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         424: bipush        13
         426: ldc           #46                 // String %,
         428: aastore
         429: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         432: bipush        14
         434: ldc           #48                 // String really_input
         436: aastore
         437: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc           #50                 // String input
         444: aastore
         445: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         448: bipush        16
         450: iconst_2
         451: anewarray     #2                  // class java/lang/Object
         454: astore_1
         455: aload_1
         456: iconst_0
         457: iconst_0
         458: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         461: aastore
         462: aload_1
         463: iconst_1
         464: iconst_2
         465: anewarray     #2                  // class java/lang/Object
         468: astore_2
         469: aload_2
         470: iconst_0
         471: bipush        6
         473: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         476: aastore
         477: aload_2
         478: iconst_1
         479: iconst_0
         480: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         483: aastore
         484: new           #18                 // class Block
         487: dup
         488: iconst_0
         489: aload_2
         490: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         493: aastore
         494: new           #18                 // class Block
         497: dup
         498: iconst_0
         499: aload_1
         500: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         503: aastore
         504: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         507: bipush        17
         509: iconst_2
         510: anewarray     #2                  // class java/lang/Object
         513: astore_1
         514: aload_1
         515: iconst_0
         516: iconst_0
         517: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         520: aastore
         521: aload_1
         522: iconst_1
         523: iconst_2
         524: anewarray     #2                  // class java/lang/Object
         527: astore_2
         528: aload_2
         529: iconst_0
         530: bipush        7
         532: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         535: aastore
         536: aload_2
         537: iconst_1
         538: iconst_0
         539: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         542: aastore
         543: new           #18                 // class Block
         546: dup
         547: iconst_0
         548: aload_2
         549: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         552: aastore
         553: new           #18                 // class Block
         556: dup
         557: iconst_0
         558: aload_1
         559: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         562: aastore
         563: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         566: bipush        18
         568: ldc           #52                 // String output_substring
         570: aastore
         571: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        19
         576: ldc           #54                 // String output
         578: aastore
         579: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         582: bipush        20
         584: iconst_2
         585: anewarray     #2                  // class java/lang/Object
         588: astore_1
         589: aload_1
         590: iconst_0
         591: iconst_1
         592: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: aload_1
         597: iconst_1
         598: iconst_2
         599: anewarray     #2                  // class java/lang/Object
         602: astore_2
         603: aload_2
         604: iconst_0
         605: iconst_3
         606: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         609: aastore
         610: aload_2
         611: iconst_1
         612: iconst_2
         613: anewarray     #2                  // class java/lang/Object
         616: astore_3
         617: aload_3
         618: iconst_0
         619: iconst_4
         620: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         623: aastore
         624: aload_3
         625: iconst_1
         626: iconst_2
         627: anewarray     #2                  // class java/lang/Object
         630: astore        4
         632: aload         4
         634: iconst_0
         635: bipush        6
         637: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         640: aastore
         641: aload         4
         643: iconst_1
         644: iconst_0
         645: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         648: aastore
         649: new           #18                 // class Block
         652: dup
         653: iconst_0
         654: aload         4
         656: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         659: aastore
         660: new           #18                 // class Block
         663: dup
         664: iconst_0
         665: aload_3
         666: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         669: aastore
         670: new           #18                 // class Block
         673: dup
         674: iconst_0
         675: aload_2
         676: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         679: aastore
         680: new           #18                 // class Block
         683: dup
         684: iconst_0
         685: aload_1
         686: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: iconst_2
         696: anewarray     #2                  // class java/lang/Object
         699: astore_1
         700: aload_1
         701: iconst_0
         702: iconst_1
         703: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         706: aastore
         707: aload_1
         708: iconst_1
         709: iconst_2
         710: anewarray     #2                  // class java/lang/Object
         713: astore_2
         714: aload_2
         715: iconst_0
         716: iconst_3
         717: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         720: aastore
         721: aload_2
         722: iconst_1
         723: iconst_2
         724: anewarray     #2                  // class java/lang/Object
         727: astore_3
         728: aload_3
         729: iconst_0
         730: iconst_4
         731: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         734: aastore
         735: aload_3
         736: iconst_1
         737: iconst_2
         738: anewarray     #2                  // class java/lang/Object
         741: astore        4
         743: aload         4
         745: iconst_0
         746: bipush        7
         748: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         751: aastore
         752: aload         4
         754: iconst_1
         755: iconst_0
         756: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         759: aastore
         760: new           #18                 // class Block
         763: dup
         764: iconst_0
         765: aload         4
         767: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         770: aastore
         771: new           #18                 // class Block
         774: dup
         775: iconst_0
         776: aload_3
         777: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: new           #18                 // class Block
         784: dup
         785: iconst_0
         786: aload_2
         787: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         790: aastore
         791: new           #18                 // class Block
         794: dup
         795: iconst_0
         796: aload_1
         797: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         800: aastore
         801: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        22
         806: ldc           #56                 // String %.12g
         808: aastore
         809: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        23
         814: ldc           #58                 // String .
         816: aastore
         817: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        24
         822: ldc           #60                 // String %d
         824: aastore
         825: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         828: bipush        25
         830: ldc           #62                 // String false
         832: aastore
         833: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         836: bipush        26
         838: ldc           #64                 // String true
         840: aastore
         841: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         844: bipush        27
         846: iconst_1
         847: anewarray     #2                  // class java/lang/Object
         850: astore_1
         851: aload_1
         852: iconst_0
         853: iconst_1
         854: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         857: aastore
         858: new           #18                 // class Block
         861: dup
         862: iconst_0
         863: aload_1
         864: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         867: aastore
         868: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         871: bipush        28
         873: iconst_1
         874: anewarray     #2                  // class java/lang/Object
         877: astore_1
         878: aload_1
         879: iconst_0
         880: iconst_0
         881: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         884: aastore
         885: new           #18                 // class Block
         888: dup
         889: iconst_0
         890: aload_1
         891: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         894: aastore
         895: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        29
         900: ldc           #62                 // String false
         902: aastore
         903: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        30
         908: ldc           #64                 // String true
         910: aastore
         911: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        31
         916: ldc           #66                 // String bool_of_string
         918: aastore
         919: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        32
         924: ldc           #64                 // String true
         926: aastore
         927: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        33
         932: ldc           #62                 // String false
         934: aastore
         935: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        34
         940: ldc           #68                 // String char_of_int
         942: aastore
         943: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        35
         948: ldc           #70                 // String index out of bounds
         950: aastore
         951: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        36
         956: ldc           #72                 // String Pervasives.array_bound_error
         958: aastore
         959: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         962: bipush        37
         964: ldc           #74                 // String Stdlib.Exit
         966: aastore
         967: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         970: bipush        44
         972: ldc           #76                 // String Pervasives.do_at_exit
         974: aastore
         975: goto          978
         978: new           #78                 // class ocaml_fn_1
         981: dup
         982: invokespecial #81                 // Method ocaml_fn_1."<init>":()V
         985: dup
         986: astore_1
         987: pop
         988: bipush        10
         990: dup
         991: istore_2
         992: pop
         993: aload_1
         994: iload_2
         995: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         998: invokevirtual #87                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        1001: checkcast     #89                 // class ocaml_fn_0
        1004: dup
        1005: astore_3
        1006: pop
        1007: bipush        32
        1009: dup
        1010: istore        4
        1012: pop
        1013: aload_3
        1014: iload         4
        1016: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1019: invokevirtual #87                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        1022: checkcast     #12                 // class java/lang/Integer
        1025: invokevirtual #93                 // Method java/lang/Integer.intValue:()I
        1028: getstatic     #99                 // Field java/lang/System.out:Ljava/io/PrintStream;
        1031: swap
        1032: invokevirtual #105                // Method java/io/PrintStream.println:(I)V
        1035: iconst_0
        1036: dup
        1037: istore        5
        1039: pop
        1040: aload_1
        1041: astore        6
        1043: iconst_1
        1044: anewarray     #2                  // class java/lang/Object
        1047: astore        7
        1049: aload         7
        1051: iconst_0
        1052: aload         6
        1054: aastore
        1055: new           #18                 // class Block
        1058: dup
        1059: iconst_0
        1060: aload         7
        1062: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1065: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        49
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: iconst_2
          13: anewarray     #2                  // class java/lang/Object
          16: astore_1
          17: aload_1
          18: iconst_0
          19: ldc           #10                 // String Out_of_memory
          21: aastore
          22: aload_1
          23: iconst_1
          24: iconst_m1
          25: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          28: aastore
          29: new           #18                 // class Block
          32: dup
          33: sipush        248
          36: aload_1
          37: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          40: aastore
          41: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          44: iconst_1
          45: iconst_2
          46: anewarray     #2                  // class java/lang/Object
          49: astore_1
          50: aload_1
          51: iconst_0
          52: ldc           #24                 // String Sys_error
          54: aastore
          55: aload_1
          56: iconst_1
          57: bipush        -2
          59: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          62: aastore
          63: new           #18                 // class Block
          66: dup
          67: sipush        248
          70: aload_1
          71: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          74: aastore
          75: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          78: iconst_2
          79: iconst_2
          80: anewarray     #2                  // class java/lang/Object
          83: astore_1
          84: aload_1
          85: iconst_0
          86: ldc           #26                 // String Failure
          88: aastore
          89: aload_1
          90: iconst_1
          91: bipush        -3
          93: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          96: aastore
          97: new           #18                 // class Block
         100: dup
         101: sipush        248
         104: aload_1
         105: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         108: aastore
         109: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         112: iconst_3
         113: iconst_2
         114: anewarray     #2                  // class java/lang/Object
         117: astore_1
         118: aload_1
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: aload_1
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: new           #18                 // class Block
         134: dup
         135: sipush        248
         138: aload_1
         139: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         142: aastore
         143: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         146: iconst_4
         147: iconst_2
         148: anewarray     #2                  // class java/lang/Object
         151: astore_1
         152: aload_1
         153: iconst_0
         154: ldc           #30                 // String End_of_file
         156: aastore
         157: aload_1
         158: iconst_1
         159: bipush        -5
         161: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: new           #18                 // class Block
         168: dup
         169: sipush        248
         172: aload_1
         173: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         176: aastore
         177: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         180: iconst_5
         181: iconst_2
         182: anewarray     #2                  // class java/lang/Object
         185: astore_1
         186: aload_1
         187: iconst_0
         188: ldc           #32                 // String Division_by_zero
         190: aastore
         191: aload_1
         192: iconst_1
         193: bipush        -6
         195: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         198: aastore
         199: new           #18                 // class Block
         202: dup
         203: sipush        248
         206: aload_1
         207: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         210: aastore
         211: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         214: bipush        6
         216: iconst_2
         217: anewarray     #2                  // class java/lang/Object
         220: astore_1
         221: aload_1
         222: iconst_0
         223: ldc           #34                 // String Not_found
         225: aastore
         226: aload_1
         227: iconst_1
         228: bipush        -7
         230: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         233: aastore
         234: new           #18                 // class Block
         237: dup
         238: sipush        248
         241: aload_1
         242: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         245: aastore
         246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         249: bipush        7
         251: iconst_2
         252: anewarray     #2                  // class java/lang/Object
         255: astore_1
         256: aload_1
         257: iconst_0
         258: ldc           #36                 // String Match_failure
         260: aastore
         261: aload_1
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: new           #18                 // class Block
         272: dup
         273: sipush        248
         276: aload_1
         277: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         280: aastore
         281: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         284: bipush        8
         286: iconst_2
         287: anewarray     #2                  // class java/lang/Object
         290: astore_1
         291: aload_1
         292: iconst_0
         293: ldc           #38                 // String Stack_overflow
         295: aastore
         296: aload_1
         297: iconst_1
         298: bipush        -9
         300: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         303: aastore
         304: new           #18                 // class Block
         307: dup
         308: sipush        248
         311: aload_1
         312: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         315: aastore
         316: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         319: bipush        9
         321: iconst_2
         322: anewarray     #2                  // class java/lang/Object
         325: astore_1
         326: aload_1
         327: iconst_0
         328: ldc           #40                 // String Sys_blocked_io
         330: aastore
         331: aload_1
         332: iconst_1
         333: bipush        -10
         335: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         338: aastore
         339: new           #18                 // class Block
         342: dup
         343: sipush        248
         346: aload_1
         347: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         350: aastore
         351: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         354: bipush        10
         356: iconst_2
         357: anewarray     #2                  // class java/lang/Object
         360: astore_1
         361: aload_1
         362: iconst_0
         363: ldc           #42                 // String Assert_failure
         365: aastore
         366: aload_1
         367: iconst_1
         368: bipush        -11
         370: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         373: aastore
         374: new           #18                 // class Block
         377: dup
         378: sipush        248
         381: aload_1
         382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         385: aastore
         386: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         389: bipush        11
         391: iconst_2
         392: anewarray     #2                  // class java/lang/Object
         395: astore_1
         396: aload_1
         397: iconst_0
         398: ldc           #44                 // String Undefined_recursive_module
         400: aastore
         401: aload_1
         402: iconst_1
         403: bipush        -12
         405: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         408: aastore
         409: new           #18                 // class Block
         412: dup
         413: sipush        248
         416: aload_1
         417: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         420: aastore
         421: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         424: bipush        13
         426: ldc           #46                 // String %,
         428: aastore
         429: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         432: bipush        14
         434: ldc           #48                 // String really_input
         436: aastore
         437: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc           #50                 // String input
         444: aastore
         445: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         448: bipush        16
         450: iconst_2
         451: anewarray     #2                  // class java/lang/Object
         454: astore_1
         455: aload_1
         456: iconst_0
         457: iconst_0
         458: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         461: aastore
         462: aload_1
         463: iconst_1
         464: iconst_2
         465: anewarray     #2                  // class java/lang/Object
         468: astore_2
         469: aload_2
         470: iconst_0
         471: bipush        6
         473: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         476: aastore
         477: aload_2
         478: iconst_1
         479: iconst_0
         480: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         483: aastore
         484: new           #18                 // class Block
         487: dup
         488: iconst_0
         489: aload_2
         490: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         493: aastore
         494: new           #18                 // class Block
         497: dup
         498: iconst_0
         499: aload_1
         500: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         503: aastore
         504: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         507: bipush        17
         509: iconst_2
         510: anewarray     #2                  // class java/lang/Object
         513: astore_1
         514: aload_1
         515: iconst_0
         516: iconst_0
         517: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         520: aastore
         521: aload_1
         522: iconst_1
         523: iconst_2
         524: anewarray     #2                  // class java/lang/Object
         527: astore_2
         528: aload_2
         529: iconst_0
         530: bipush        7
         532: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         535: aastore
         536: aload_2
         537: iconst_1
         538: iconst_0
         539: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         542: aastore
         543: new           #18                 // class Block
         546: dup
         547: iconst_0
         548: aload_2
         549: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         552: aastore
         553: new           #18                 // class Block
         556: dup
         557: iconst_0
         558: aload_1
         559: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         562: aastore
         563: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         566: bipush        18
         568: ldc           #52                 // String output_substring
         570: aastore
         571: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        19
         576: ldc           #54                 // String output
         578: aastore
         579: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         582: bipush        20
         584: iconst_2
         585: anewarray     #2                  // class java/lang/Object
         588: astore_1
         589: aload_1
         590: iconst_0
         591: iconst_1
         592: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: aload_1
         597: iconst_1
         598: iconst_2
         599: anewarray     #2                  // class java/lang/Object
         602: astore_2
         603: aload_2
         604: iconst_0
         605: iconst_3
         606: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         609: aastore
         610: aload_2
         611: iconst_1
         612: iconst_2
         613: anewarray     #2                  // class java/lang/Object
         616: astore_3
         617: aload_3
         618: iconst_0
         619: iconst_4
         620: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         623: aastore
         624: aload_3
         625: iconst_1
         626: iconst_2
         627: anewarray     #2                  // class java/lang/Object
         630: astore        4
         632: aload         4
         634: iconst_0
         635: bipush        6
         637: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         640: aastore
         641: aload         4
         643: iconst_1
         644: iconst_0
         645: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         648: aastore
         649: new           #18                 // class Block
         652: dup
         653: iconst_0
         654: aload         4
         656: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         659: aastore
         660: new           #18                 // class Block
         663: dup
         664: iconst_0
         665: aload_3
         666: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         669: aastore
         670: new           #18                 // class Block
         673: dup
         674: iconst_0
         675: aload_2
         676: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         679: aastore
         680: new           #18                 // class Block
         683: dup
         684: iconst_0
         685: aload_1
         686: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: iconst_2
         696: anewarray     #2                  // class java/lang/Object
         699: astore_1
         700: aload_1
         701: iconst_0
         702: iconst_1
         703: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         706: aastore
         707: aload_1
         708: iconst_1
         709: iconst_2
         710: anewarray     #2                  // class java/lang/Object
         713: astore_2
         714: aload_2
         715: iconst_0
         716: iconst_3
         717: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         720: aastore
         721: aload_2
         722: iconst_1
         723: iconst_2
         724: anewarray     #2                  // class java/lang/Object
         727: astore_3
         728: aload_3
         729: iconst_0
         730: iconst_4
         731: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         734: aastore
         735: aload_3
         736: iconst_1
         737: iconst_2
         738: anewarray     #2                  // class java/lang/Object
         741: astore        4
         743: aload         4
         745: iconst_0
         746: bipush        7
         748: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         751: aastore
         752: aload         4
         754: iconst_1
         755: iconst_0
         756: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         759: aastore
         760: new           #18                 // class Block
         763: dup
         764: iconst_0
         765: aload         4
         767: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         770: aastore
         771: new           #18                 // class Block
         774: dup
         775: iconst_0
         776: aload_3
         777: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: new           #18                 // class Block
         784: dup
         785: iconst_0
         786: aload_2
         787: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         790: aastore
         791: new           #18                 // class Block
         794: dup
         795: iconst_0
         796: aload_1
         797: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         800: aastore
         801: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        22
         806: ldc           #56                 // String %.12g
         808: aastore
         809: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        23
         814: ldc           #58                 // String .
         816: aastore
         817: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        24
         822: ldc           #60                 // String %d
         824: aastore
         825: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         828: bipush        25
         830: ldc           #62                 // String false
         832: aastore
         833: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         836: bipush        26
         838: ldc           #64                 // String true
         840: aastore
         841: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         844: bipush        27
         846: iconst_1
         847: anewarray     #2                  // class java/lang/Object
         850: astore_1
         851: aload_1
         852: iconst_0
         853: iconst_1
         854: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         857: aastore
         858: new           #18                 // class Block
         861: dup
         862: iconst_0
         863: aload_1
         864: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         867: aastore
         868: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         871: bipush        28
         873: iconst_1
         874: anewarray     #2                  // class java/lang/Object
         877: astore_1
         878: aload_1
         879: iconst_0
         880: iconst_0
         881: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         884: aastore
         885: new           #18                 // class Block
         888: dup
         889: iconst_0
         890: aload_1
         891: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         894: aastore
         895: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        29
         900: ldc           #62                 // String false
         902: aastore
         903: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        30
         908: ldc           #64                 // String true
         910: aastore
         911: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        31
         916: ldc           #66                 // String bool_of_string
         918: aastore
         919: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        32
         924: ldc           #64                 // String true
         926: aastore
         927: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        33
         932: ldc           #62                 // String false
         934: aastore
         935: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        34
         940: ldc           #68                 // String char_of_int
         942: aastore
         943: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        35
         948: ldc           #70                 // String index out of bounds
         950: aastore
         951: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        36
         956: ldc           #72                 // String Pervasives.array_bound_error
         958: aastore
         959: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         962: bipush        37
         964: ldc           #74                 // String Stdlib.Exit
         966: aastore
         967: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         970: bipush        44
         972: ldc           #76                 // String Pervasives.do_at_exit
         974: aastore
         975: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        46
         980: iconst_1
         981: anewarray     #2                  // class java/lang/Object
         984: astore_1
         985: aload_1
         986: iconst_0
         987: bipush        42
         989: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         992: aastore
         993: new           #18                 // class Block
         996: dup
         997: iconst_0
         998: aload_1
         999: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1002: aastore
        1003: goto          1006
        1006: new           #78                 // class ocaml_fn_0
        1009: dup
        1010: invokespecial #81                 // Method ocaml_fn_0."<init>":()V
        1013: dup
        1014: astore_1
        1015: pop
        1016: iconst_1
        1017: anewarray     #2                  // class java/lang/Object
        1020: astore_2
        1021: aload_2
        1022: iconst_0
        1023: bipush        42
        1025: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1028: aastore
        1029: new           #18                 // class Block
        1032: dup
        1033: iconst_0
        1034: aload_2
        1035: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1038: dup
        1039: astore_3
        1040: pop
        1041: aload_1
        1042: aload_3
        1043: invokevirtual #87                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        1046: checkcast     #12                 // class java/lang/Integer
        1049: invokevirtual #91                 // Method java/lang/Integer.intValue:()I
        1052: getstatic     #97                 // Field java/lang/System.out:Ljava/io/PrintStream;
        1055: swap
        1056: invokevirtual #103                // Method java/io/PrintStream.println:(I)V
        1059: iconst_0
        1060: dup
        1061: istore        4
        1063: pop
        1064: aload_1
        1065: astore        5
        1067: iconst_1
        1068: anewarray     #2                  // class java/lang/Object
        1071: astore        6
        1073: aload         6
        1075: iconst_0
        1076: aload         5
        1078: aastore
        1079: new           #18                 // class Block
        1082: dup
        1083: iconst_0
        1084: aload         6
        1086: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1089: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        49
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: iconst_2
          13: anewarray     #2                  // class java/lang/Object
          16: astore_1
          17: aload_1
          18: iconst_0
          19: ldc           #10                 // String Out_of_memory
          21: aastore
          22: aload_1
          23: iconst_1
          24: iconst_m1
          25: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          28: aastore
          29: new           #18                 // class Block
          32: dup
          33: sipush        248
          36: aload_1
          37: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          40: aastore
          41: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          44: iconst_1
          45: iconst_2
          46: anewarray     #2                  // class java/lang/Object
          49: astore_1
          50: aload_1
          51: iconst_0
          52: ldc           #24                 // String Sys_error
          54: aastore
          55: aload_1
          56: iconst_1
          57: bipush        -2
          59: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          62: aastore
          63: new           #18                 // class Block
          66: dup
          67: sipush        248
          70: aload_1
          71: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          74: aastore
          75: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          78: iconst_2
          79: iconst_2
          80: anewarray     #2                  // class java/lang/Object
          83: astore_1
          84: aload_1
          85: iconst_0
          86: ldc           #26                 // String Failure
          88: aastore
          89: aload_1
          90: iconst_1
          91: bipush        -3
          93: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          96: aastore
          97: new           #18                 // class Block
         100: dup
         101: sipush        248
         104: aload_1
         105: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         108: aastore
         109: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         112: iconst_3
         113: iconst_2
         114: anewarray     #2                  // class java/lang/Object
         117: astore_1
         118: aload_1
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: aload_1
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: new           #18                 // class Block
         134: dup
         135: sipush        248
         138: aload_1
         139: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         142: aastore
         143: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         146: iconst_4
         147: iconst_2
         148: anewarray     #2                  // class java/lang/Object
         151: astore_1
         152: aload_1
         153: iconst_0
         154: ldc           #30                 // String End_of_file
         156: aastore
         157: aload_1
         158: iconst_1
         159: bipush        -5
         161: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: new           #18                 // class Block
         168: dup
         169: sipush        248
         172: aload_1
         173: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         176: aastore
         177: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         180: iconst_5
         181: iconst_2
         182: anewarray     #2                  // class java/lang/Object
         185: astore_1
         186: aload_1
         187: iconst_0
         188: ldc           #32                 // String Division_by_zero
         190: aastore
         191: aload_1
         192: iconst_1
         193: bipush        -6
         195: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         198: aastore
         199: new           #18                 // class Block
         202: dup
         203: sipush        248
         206: aload_1
         207: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         210: aastore
         211: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         214: bipush        6
         216: iconst_2
         217: anewarray     #2                  // class java/lang/Object
         220: astore_1
         221: aload_1
         222: iconst_0
         223: ldc           #34                 // String Not_found
         225: aastore
         226: aload_1
         227: iconst_1
         228: bipush        -7
         230: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         233: aastore
         234: new           #18                 // class Block
         237: dup
         238: sipush        248
         241: aload_1
         242: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         245: aastore
         246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         249: bipush        7
         251: iconst_2
         252: anewarray     #2                  // class java/lang/Object
         255: astore_1
         256: aload_1
         257: iconst_0
         258: ldc           #36                 // String Match_failure
         260: aastore
         261: aload_1
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: new           #18                 // class Block
         272: dup
         273: sipush        248
         276: aload_1
         277: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         280: aastore
         281: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         284: bipush        8
         286: iconst_2
         287: anewarray     #2                  // class java/lang/Object
         290: astore_1
         291: aload_1
         292: iconst_0
         293: ldc           #38                 // String Stack_overflow
         295: aastore
         296: aload_1
         297: iconst_1
         298: bipush        -9
         300: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         303: aastore
         304: new           #18                 // class Block
         307: dup
         308: sipush        248
         311: aload_1
         312: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         315: aastore
         316: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         319: bipush        9
         321: iconst_2
         322: anewarray     #2                  // class java/lang/Object
         325: astore_1
         326: aload_1
         327: iconst_0
         328: ldc           #40                 // String Sys_blocked_io
         330: aastore
         331: aload_1
         332: iconst_1
         333: bipush        -10
         335: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         338: aastore
         339: new           #18                 // class Block
         342: dup
         343: sipush        248
         346: aload_1
         347: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         350: aastore
         351: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         354: bipush        10
         356: iconst_2
         357: anewarray     #2                  // class java/lang/Object
         360: astore_1
         361: aload_1
         362: iconst_0
         363: ldc           #42                 // String Assert_failure
         365: aastore
         366: aload_1
         367: iconst_1
         368: bipush        -11
         370: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         373: aastore
         374: new           #18                 // class Block
         377: dup
         378: sipush        248
         381: aload_1
         382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         385: aastore
         386: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         389: bipush        11
         391: iconst_2
         392: anewarray     #2                  // class java/lang/Object
         395: astore_1
         396: aload_1
         397: iconst_0
         398: ldc           #44                 // String Undefined_recursive_module
         400: aastore
         401: aload_1
         402: iconst_1
         403: bipush        -12
         405: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         408: aastore
         409: new           #18                 // class Block
         412: dup
         413: sipush        248
         416: aload_1
         417: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         420: aastore
         421: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         424: bipush        13
         426: ldc           #46                 // String %,
         428: aastore
         429: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         432: bipush        14
         434: ldc           #48                 // String really_input
         436: aastore
         437: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc           #50                 // String input
         444: aastore
         445: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         448: bipush        16
         450: iconst_2
         451: anewarray     #2                  // class java/lang/Object
         454: astore_1
         455: aload_1
         456: iconst_0
         457: iconst_0
         458: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         461: aastore
         462: aload_1
         463: iconst_1
         464: iconst_2
         465: anewarray     #2                  // class java/lang/Object
         468: astore_2
         469: aload_2
         470: iconst_0
         471: bipush        6
         473: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         476: aastore
         477: aload_2
         478: iconst_1
         479: iconst_0
         480: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         483: aastore
         484: new           #18                 // class Block
         487: dup
         488: iconst_0
         489: aload_2
         490: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         493: aastore
         494: new           #18                 // class Block
         497: dup
         498: iconst_0
         499: aload_1
         500: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         503: aastore
         504: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         507: bipush        17
         509: iconst_2
         510: anewarray     #2                  // class java/lang/Object
         513: astore_1
         514: aload_1
         515: iconst_0
         516: iconst_0
         517: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         520: aastore
         521: aload_1
         522: iconst_1
         523: iconst_2
         524: anewarray     #2                  // class java/lang/Object
         527: astore_2
         528: aload_2
         529: iconst_0
         530: bipush        7
         532: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         535: aastore
         536: aload_2
         537: iconst_1
         538: iconst_0
         539: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         542: aastore
         543: new           #18                 // class Block
         546: dup
         547: iconst_0
         548: aload_2
         549: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         552: aastore
         553: new           #18                 // class Block
         556: dup
         557: iconst_0
         558: aload_1
         559: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         562: aastore
         563: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         566: bipush        18
         568: ldc           #52                 // String output_substring
         570: aastore
         571: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        19
         576: ldc           #54                 // String output
         578: aastore
         579: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         582: bipush        20
         584: iconst_2
         585: anewarray     #2                  // class java/lang/Object
         588: astore_1
         589: aload_1
         590: iconst_0
         591: iconst_1
         592: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: aload_1
         597: iconst_1
         598: iconst_2
         599: anewarray     #2                  // class java/lang/Object
         602: astore_2
         603: aload_2
         604: iconst_0
         605: iconst_3
         606: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         609: aastore
         610: aload_2
         611: iconst_1
         612: iconst_2
         613: anewarray     #2                  // class java/lang/Object
         616: astore_3
         617: aload_3
         618: iconst_0
         619: iconst_4
         620: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         623: aastore
         624: aload_3
         625: iconst_1
         626: iconst_2
         627: anewarray     #2                  // class java/lang/Object
         630: astore        4
         632: aload         4
         634: iconst_0
         635: bipush        6
         637: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         640: aastore
         641: aload         4
         643: iconst_1
         644: iconst_0
         645: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         648: aastore
         649: new           #18                 // class Block
         652: dup
         653: iconst_0
         654: aload         4
         656: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         659: aastore
         660: new           #18                 // class Block
         663: dup
         664: iconst_0
         665: aload_3
         666: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         669: aastore
         670: new           #18                 // class Block
         673: dup
         674: iconst_0
         675: aload_2
         676: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         679: aastore
         680: new           #18                 // class Block
         683: dup
         684: iconst_0
         685: aload_1
         686: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: iconst_2
         696: anewarray     #2                  // class java/lang/Object
         699: astore_1
         700: aload_1
         701: iconst_0
         702: iconst_1
         703: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         706: aastore
         707: aload_1
         708: iconst_1
         709: iconst_2
         710: anewarray     #2                  // class java/lang/Object
         713: astore_2
         714: aload_2
         715: iconst_0
         716: iconst_3
         717: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         720: aastore
         721: aload_2
         722: iconst_1
         723: iconst_2
         724: anewarray     #2                  // class java/lang/Object
         727: astore_3
         728: aload_3
         729: iconst_0
         730: iconst_4
         731: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         734: aastore
         735: aload_3
         736: iconst_1
         737: iconst_2
         738: anewarray     #2                  // class java/lang/Object
         741: astore        4
         743: aload         4
         745: iconst_0
         746: bipush        7
         748: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         751: aastore
         752: aload         4
         754: iconst_1
         755: iconst_0
         756: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         759: aastore
         760: new           #18                 // class Block
         763: dup
         764: iconst_0
         765: aload         4
         767: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         770: aastore
         771: new           #18                 // class Block
         774: dup
         775: iconst_0
         776: aload_3
         777: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: new           #18                 // class Block
         784: dup
         785: iconst_0
         786: aload_2
         787: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         790: aastore
         791: new           #18                 // class Block
         794: dup
         795: iconst_0
         796: aload_1
         797: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         800: aastore
         801: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        22
         806: ldc           #56                 // String %.12g
         808: aastore
         809: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        23
         814: ldc           #58                 // String .
         816: aastore
         817: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        24
         822: ldc           #60                 // String %d
         824: aastore
         825: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         828: bipush        25
         830: ldc           #62                 // String false
         832: aastore
         833: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         836: bipush        26
         838: ldc           #64                 // String true
         840: aastore
         841: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         844: bipush        27
         846: iconst_1
         847: anewarray     #2                  // class java/lang/Object
         850: astore_1
         851: aload_1
         852: iconst_0
         853: iconst_1
         854: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         857: aastore
         858: new           #18                 // class Block
         861: dup
         862: iconst_0
         863: aload_1
         864: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         867: aastore
         868: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         871: bipush        28
         873: iconst_1
         874: anewarray     #2                  // class java/lang/Object
         877: astore_1
         878: aload_1
         879: iconst_0
         880: iconst_0
         881: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         884: aastore
         885: new           #18                 // class Block
         888: dup
         889: iconst_0
         890: aload_1
         891: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         894: aastore
         895: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        29
         900: ldc           #62                 // String false
         902: aastore
         903: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        30
         908: ldc           #64                 // String true
         910: aastore
         911: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        31
         916: ldc           #66                 // String bool_of_string
         918: aastore
         919: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        32
         924: ldc           #64                 // String true
         926: aastore
         927: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        33
         932: ldc           #62                 // String false
         934: aastore
         935: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        34
         940: ldc           #68                 // String char_of_int
         942: aastore
         943: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        35
         948: ldc           #70                 // String index out of bounds
         950: aastore
         951: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        36
         956: ldc           #72                 // String Pervasives.array_bound_error
         958: aastore
         959: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         962: bipush        37
         964: ldc           #74                 // String Stdlib.Exit
         966: aastore
         967: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         970: bipush        44
         972: ldc           #76                 // String Pervasives.do_at_exit
         974: aastore
         975: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         978: bipush        46
         980: ldc           #78                 // String Test.Oops
         982: aastore
         983: goto          986
         986: iconst_0
         987: pop
         988: iconst_0
         989: dup
         990: istore_1
         991: pop
         992: ldc           #78                 // String Test.Oops
         994: astore_2
         995: iconst_2
         996: anewarray     #2                  // class java/lang/Object
         999: astore_3
        1000: aload_3
        1001: iconst_0
        1002: aload_2
        1003: aastore
        1004: aload_3
        1005: iconst_1
        1006: iload_1
        1007: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1010: aastore
        1011: new           #18                 // class Block
        1014: dup
        1015: sipush        248
        1018: aload_3
        1019: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1022: dup
        1023: astore        4
        1025: pop
        1026: aload         4
        1028: dup
        1029: astore        5
        1031: pop
        1032: new           #80                 // class ocaml_fn_0
        1035: dup
        1036: aload         5
        1038: invokespecial #83                 // Method ocaml_fn_0."<init>":(LBlock;)V
        1041: dup
        1042: astore        6
        1044: pop
        1045: iconst_0
        1046: dup
        1047: istore        7
        1049: pop
        1050: aload         6
        1052: iload         7
        1054: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
        1057: invokevirtual #89                 // Method Closure.apply1:(Ljava/lang/Object;)Ljava/lang/Object;
        1060: checkcast     #12                 // class java/lang/Integer
        1063: invokevirtual #93                 // Method java/lang/Integer.intValue:()I
        1066: getstatic     #99                 // Field java/lang/System.out:Ljava/io/PrintStream;
        1069: swap
        1070: invokevirtual #105                // Method java/io/PrintStream.println:(I)V
        1073: iconst_0
        1074: dup
        1075: istore        8
        1077: pop
        1078: aload         6
        1080: dup
        1081: astore        9
        1083: pop
        1084: aload         4
        1086: astore        10
        1088: iconst_2
        1089: anewarray     #2                  // class java/lang/Object
        1092: astore        11
        1094: aload         11
        1096: iconst_0
        1097: aload         10
        1099: aastore
        1100: aload         11
        1102: iconst_1
        1103: aload         9
        1105: aastore
        1106: new           #18                 // class Block
        1109: dup
        1110: iconst_0
        1111: aload         11
        1113: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
        1116: return
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

      public static void main(java.lang.String[]);
        Code:
           0: bipush        48
           2: anewarray     #2                  // class java/lang/Object
           5: putstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
           8: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          11: iconst_0
          12: iconst_2
          13: anewarray     #2                  // class java/lang/Object
          16: astore_1
          17: aload_1
          18: iconst_0
          19: ldc           #10                 // String Out_of_memory
          21: aastore
          22: aload_1
          23: iconst_1
          24: iconst_m1
          25: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          28: aastore
          29: new           #18                 // class Block
          32: dup
          33: sipush        248
          36: aload_1
          37: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          40: aastore
          41: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          44: iconst_1
          45: iconst_2
          46: anewarray     #2                  // class java/lang/Object
          49: astore_1
          50: aload_1
          51: iconst_0
          52: ldc           #24                 // String Sys_error
          54: aastore
          55: aload_1
          56: iconst_1
          57: bipush        -2
          59: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          62: aastore
          63: new           #18                 // class Block
          66: dup
          67: sipush        248
          70: aload_1
          71: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
          74: aastore
          75: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
          78: iconst_2
          79: iconst_2
          80: anewarray     #2                  // class java/lang/Object
          83: astore_1
          84: aload_1
          85: iconst_0
          86: ldc           #26                 // String Failure
          88: aastore
          89: aload_1
          90: iconst_1
          91: bipush        -3
          93: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
          96: aastore
          97: new           #18                 // class Block
         100: dup
         101: sipush        248
         104: aload_1
         105: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         108: aastore
         109: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         112: iconst_3
         113: iconst_2
         114: anewarray     #2                  // class java/lang/Object
         117: astore_1
         118: aload_1
         119: iconst_0
         120: ldc           #28                 // String Invalid_argument
         122: aastore
         123: aload_1
         124: iconst_1
         125: bipush        -4
         127: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         130: aastore
         131: new           #18                 // class Block
         134: dup
         135: sipush        248
         138: aload_1
         139: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         142: aastore
         143: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         146: iconst_4
         147: iconst_2
         148: anewarray     #2                  // class java/lang/Object
         151: astore_1
         152: aload_1
         153: iconst_0
         154: ldc           #30                 // String End_of_file
         156: aastore
         157: aload_1
         158: iconst_1
         159: bipush        -5
         161: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         164: aastore
         165: new           #18                 // class Block
         168: dup
         169: sipush        248
         172: aload_1
         173: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         176: aastore
         177: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         180: iconst_5
         181: iconst_2
         182: anewarray     #2                  // class java/lang/Object
         185: astore_1
         186: aload_1
         187: iconst_0
         188: ldc           #32                 // String Division_by_zero
         190: aastore
         191: aload_1
         192: iconst_1
         193: bipush        -6
         195: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         198: aastore
         199: new           #18                 // class Block
         202: dup
         203: sipush        248
         206: aload_1
         207: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         210: aastore
         211: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         214: bipush        6
         216: iconst_2
         217: anewarray     #2                  // class java/lang/Object
         220: astore_1
         221: aload_1
         222: iconst_0
         223: ldc           #34                 // String Not_found
         225: aastore
         226: aload_1
         227: iconst_1
         228: bipush        -7
         230: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         233: aastore
         234: new           #18                 // class Block
         237: dup
         238: sipush        248
         241: aload_1
         242: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         245: aastore
         246: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         249: bipush        7
         251: iconst_2
         252: anewarray     #2                  // class java/lang/Object
         255: astore_1
         256: aload_1
         257: iconst_0
         258: ldc           #36                 // String Match_failure
         260: aastore
         261: aload_1
         262: iconst_1
         263: bipush        -8
         265: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         268: aastore
         269: new           #18                 // class Block
         272: dup
         273: sipush        248
         276: aload_1
         277: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         280: aastore
         281: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         284: bipush        8
         286: iconst_2
         287: anewarray     #2                  // class java/lang/Object
         290: astore_1
         291: aload_1
         292: iconst_0
         293: ldc           #38                 // String Stack_overflow
         295: aastore
         296: aload_1
         297: iconst_1
         298: bipush        -9
         300: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         303: aastore
         304: new           #18                 // class Block
         307: dup
         308: sipush        248
         311: aload_1
         312: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         315: aastore
         316: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         319: bipush        9
         321: iconst_2
         322: anewarray     #2                  // class java/lang/Object
         325: astore_1
         326: aload_1
         327: iconst_0
         328: ldc           #40                 // String Sys_blocked_io
         330: aastore
         331: aload_1
         332: iconst_1
         333: bipush        -10
         335: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         338: aastore
         339: new           #18                 // class Block
         342: dup
         343: sipush        248
         346: aload_1
         347: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         350: aastore
         351: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         354: bipush        10
         356: iconst_2
         357: anewarray     #2                  // class java/lang/Object
         360: astore_1
         361: aload_1
         362: iconst_0
         363: ldc           #42                 // String Assert_failure
         365: aastore
         366: aload_1
         367: iconst_1
         368: bipush        -11
         370: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         373: aastore
         374: new           #18                 // class Block
         377: dup
         378: sipush        248
         381: aload_1
         382: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         385: aastore
         386: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         389: bipush        11
         391: iconst_2
         392: anewarray     #2                  // class java/lang/Object
         395: astore_1
         396: aload_1
         397: iconst_0
         398: ldc           #44                 // String Undefined_recursive_module
         400: aastore
         401: aload_1
         402: iconst_1
         403: bipush        -12
         405: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         408: aastore
         409: new           #18                 // class Block
         412: dup
         413: sipush        248
         416: aload_1
         417: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         420: aastore
         421: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         424: bipush        13
         426: ldc           #46                 // String %,
         428: aastore
         429: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         432: bipush        14
         434: ldc           #48                 // String really_input
         436: aastore
         437: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         440: bipush        15
         442: ldc           #50                 // String input
         444: aastore
         445: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         448: bipush        16
         450: iconst_2
         451: anewarray     #2                  // class java/lang/Object
         454: astore_1
         455: aload_1
         456: iconst_0
         457: iconst_0
         458: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         461: aastore
         462: aload_1
         463: iconst_1
         464: iconst_2
         465: anewarray     #2                  // class java/lang/Object
         468: astore_2
         469: aload_2
         470: iconst_0
         471: bipush        6
         473: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         476: aastore
         477: aload_2
         478: iconst_1
         479: iconst_0
         480: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         483: aastore
         484: new           #18                 // class Block
         487: dup
         488: iconst_0
         489: aload_2
         490: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         493: aastore
         494: new           #18                 // class Block
         497: dup
         498: iconst_0
         499: aload_1
         500: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         503: aastore
         504: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         507: bipush        17
         509: iconst_2
         510: anewarray     #2                  // class java/lang/Object
         513: astore_1
         514: aload_1
         515: iconst_0
         516: iconst_0
         517: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         520: aastore
         521: aload_1
         522: iconst_1
         523: iconst_2
         524: anewarray     #2                  // class java/lang/Object
         527: astore_2
         528: aload_2
         529: iconst_0
         530: bipush        7
         532: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         535: aastore
         536: aload_2
         537: iconst_1
         538: iconst_0
         539: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         542: aastore
         543: new           #18                 // class Block
         546: dup
         547: iconst_0
         548: aload_2
         549: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         552: aastore
         553: new           #18                 // class Block
         556: dup
         557: iconst_0
         558: aload_1
         559: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         562: aastore
         563: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         566: bipush        18
         568: ldc           #52                 // String output_substring
         570: aastore
         571: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         574: bipush        19
         576: ldc           #54                 // String output
         578: aastore
         579: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         582: bipush        20
         584: iconst_2
         585: anewarray     #2                  // class java/lang/Object
         588: astore_1
         589: aload_1
         590: iconst_0
         591: iconst_1
         592: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         595: aastore
         596: aload_1
         597: iconst_1
         598: iconst_2
         599: anewarray     #2                  // class java/lang/Object
         602: astore_2
         603: aload_2
         604: iconst_0
         605: iconst_3
         606: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         609: aastore
         610: aload_2
         611: iconst_1
         612: iconst_2
         613: anewarray     #2                  // class java/lang/Object
         616: astore_3
         617: aload_3
         618: iconst_0
         619: iconst_4
         620: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         623: aastore
         624: aload_3
         625: iconst_1
         626: iconst_2
         627: anewarray     #2                  // class java/lang/Object
         630: astore        4
         632: aload         4
         634: iconst_0
         635: bipush        6
         637: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         640: aastore
         641: aload         4
         643: iconst_1
         644: iconst_0
         645: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         648: aastore
         649: new           #18                 // class Block
         652: dup
         653: iconst_0
         654: aload         4
         656: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         659: aastore
         660: new           #18                 // class Block
         663: dup
         664: iconst_0
         665: aload_3
         666: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         669: aastore
         670: new           #18                 // class Block
         673: dup
         674: iconst_0
         675: aload_2
         676: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         679: aastore
         680: new           #18                 // class Block
         683: dup
         684: iconst_0
         685: aload_1
         686: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         689: aastore
         690: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         693: bipush        21
         695: iconst_2
         696: anewarray     #2                  // class java/lang/Object
         699: astore_1
         700: aload_1
         701: iconst_0
         702: iconst_1
         703: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         706: aastore
         707: aload_1
         708: iconst_1
         709: iconst_2
         710: anewarray     #2                  // class java/lang/Object
         713: astore_2
         714: aload_2
         715: iconst_0
         716: iconst_3
         717: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         720: aastore
         721: aload_2
         722: iconst_1
         723: iconst_2
         724: anewarray     #2                  // class java/lang/Object
         727: astore_3
         728: aload_3
         729: iconst_0
         730: iconst_4
         731: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         734: aastore
         735: aload_3
         736: iconst_1
         737: iconst_2
         738: anewarray     #2                  // class java/lang/Object
         741: astore        4
         743: aload         4
         745: iconst_0
         746: bipush        7
         748: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         751: aastore
         752: aload         4
         754: iconst_1
         755: iconst_0
         756: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         759: aastore
         760: new           #18                 // class Block
         763: dup
         764: iconst_0
         765: aload         4
         767: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         770: aastore
         771: new           #18                 // class Block
         774: dup
         775: iconst_0
         776: aload_3
         777: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         780: aastore
         781: new           #18                 // class Block
         784: dup
         785: iconst_0
         786: aload_2
         787: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         790: aastore
         791: new           #18                 // class Block
         794: dup
         795: iconst_0
         796: aload_1
         797: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         800: aastore
         801: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         804: bipush        22
         806: ldc           #56                 // String %.12g
         808: aastore
         809: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         812: bipush        23
         814: ldc           #58                 // String .
         816: aastore
         817: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         820: bipush        24
         822: ldc           #60                 // String %d
         824: aastore
         825: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         828: bipush        25
         830: ldc           #62                 // String false
         832: aastore
         833: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         836: bipush        26
         838: ldc           #64                 // String true
         840: aastore
         841: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         844: bipush        27
         846: iconst_1
         847: anewarray     #2                  // class java/lang/Object
         850: astore_1
         851: aload_1
         852: iconst_0
         853: iconst_1
         854: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         857: aastore
         858: new           #18                 // class Block
         861: dup
         862: iconst_0
         863: aload_1
         864: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         867: aastore
         868: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         871: bipush        28
         873: iconst_1
         874: anewarray     #2                  // class java/lang/Object
         877: astore_1
         878: aload_1
         879: iconst_0
         880: iconst_0
         881: invokestatic  #16                 // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
         884: aastore
         885: new           #18                 // class Block
         888: dup
         889: iconst_0
         890: aload_1
         891: invokespecial #22                 // Method Block."<init>":(I[Ljava/lang/Object;)V
         894: aastore
         895: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         898: bipush        29
         900: ldc           #62                 // String false
         902: aastore
         903: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         906: bipush        30
         908: ldc           #64                 // String true
         910: aastore
         911: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         914: bipush        31
         916: ldc           #66                 // String bool_of_string
         918: aastore
         919: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         922: bipush        32
         924: ldc           #64                 // String true
         926: aastore
         927: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         930: bipush        33
         932: ldc           #62                 // String false
         934: aastore
         935: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         938: bipush        34
         940: ldc           #68                 // String char_of_int
         942: aastore
         943: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         946: bipush        35
         948: ldc           #70                 // String index out of bounds
         950: aastore
         951: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         954: bipush        36
         956: ldc           #72                 // String Pervasives.array_bound_error
         958: aastore
         959: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         962: bipush        37
         964: ldc           #74                 // String Stdlib.Exit
         966: aastore
         967: getstatic     #8                  // Field GLOBALS:[Ljava/lang/Object;
         970: bipush        44
         972: ldc           #76                 // String Pervasives.do_at_exit
         974: aastore
         975: iconst_1
         976: iconst_2
         977: if_icmpge     985
         980: bipush        10
         982: goto          987
         985: bipush        20
         987: getstatic     #82                 // Field java/lang/System.out:Ljava/io/PrintStream;
         990: swap
         991: invokevirtual #88                 // Method java/io/PrintStream.println:(I)V
         994: iconst_0
         995: dup
         996: istore_1
         997: return
    }
    |}]
