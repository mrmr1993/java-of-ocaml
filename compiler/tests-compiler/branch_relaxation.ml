(* Branch relaxation: short (3-byte) conditional branches with an
   offset that overflows the signed 16-bit field must be rewritten
   to an [if_!cond +8; goto_w L] trampoline, and short [goto]s
   upgraded to [goto_w]. Exercise both by synthesising a class file
   directly against the [Jvm.Code] API — far more compact than
   trying to coax OCaml bytecode into producing a >32 KB method. *)

open Java_of_ocaml_compiler

let exe name = try Sys.getenv name with Not_found -> name

let with_temp_dir ~f =
  let tmp =
    Filename.concat (Filename.get_temp_dir_name ()) ("jobr-" ^ string_of_int (Unix.getpid ()))
  in
  let rec rm_rec path =
    if Sys.file_exists path
    then
      if Sys.is_directory path
      then (
        Array.iter
          (fun n -> rm_rec (Filename.concat path n))
          (Sys.readdir path);
        Unix.rmdir path)
      else Sys.remove path
  in
  rm_rec tmp;
  Unix.mkdir tmp 0o755;
  let r = f tmp in
  rm_rec tmp;
  r

let write_class ~dir ~name bytes =
  let oc = open_out_bin (Filename.concat dir (name ^ ".class")) in
  output_string oc bytes;
  close_out oc

let run_java ~dir ~classname =
  let cmd = Printf.sprintf "%s -cp %s %s" (exe "java") dir classname in
  let ic = Unix.open_process_in cmd in
  let buf = Buffer.create 64 in
  (try
     while true do
       Buffer.add_channel buf ic 4096
     done
   with End_of_file -> ());
  let _status = Unix.close_process_in ic in
  Buffer.contents buf

(* Emit [target_bytes] bytes of no-effect padding to force the
   intervening JVM range past the 16-bit short-branch limit. Each
   iteration emits 2 bytes ([iconst_0; pop], 0x03 0x57). *)
let emit_padding code ~bytes =
  let n = (bytes + 1) / 2 in
  for _ = 1 to n do
    Jvm.Code.ldc_int code 0;
    Jvm.Code.pop_top code
  done

let print_hello code s =
  Jvm.Code.getstatic
    code
    ~class_:"java/lang/System"
    ~field:"out"
    ~descriptor:"Ljava/io/PrintStream;";
  Jvm.Code.ldc_string code s;
  Jvm.Code.invokevirtual
    code
    ~class_:"java/io/PrintStream"
    ~method_:"println"
    ~descriptor:"(Ljava/lang/String;)V"

let build_main build =
  let cp = Jvm.Cp.create () in
  let code = Jvm.Code.create cp in
  build code;
  Jvm.Code.return_void code;
  Jvm.assemble_class
    ~class_name:"Relax"
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:[]
    ~methods:
      [ { Jvm.name = "main"
        ; descriptor = "([Ljava/lang/String;)V"
        ; access_flags = 0x0009
        ; code
        }
      ]
    ~access_flags:0x0021
    ()

let%expect_test "conditional branch past the 16-bit window is widened" =
  with_temp_dir ~f:(fun dir ->
    let bytes =
      build_main (fun code ->
        let target = Jvm.Code.fresh_label code in
        (* [ifeq target]: pop 0 (never equal in our setup below),
           always fall through. *)
        Jvm.Code.ldc_int code 1;
        Jvm.Code.ifeq code target;
        emit_padding code ~bytes:40_000;
        Jvm.Code.mark_label code target;
        print_hello code "widened-cond")
    in
    write_class ~dir ~name:"Relax" bytes;
    print_string (run_java ~dir ~classname:"Relax"));
  [%expect {| widened-cond |}]

let%expect_test "unconditional goto past the 16-bit window is upgraded" =
  with_temp_dir ~f:(fun dir ->
    let bytes =
      build_main (fun code ->
        let target = Jvm.Code.fresh_label code in
        Jvm.Code.goto code target;
        emit_padding code ~bytes:40_000;
        (* Dead code along the fall-through; never reached because
           [goto] jumps unconditionally. *)
        print_hello code "unreached";
        Jvm.Code.mark_label code target;
        print_hello code "widened-goto")
    in
    write_class ~dir ~name:"Relax" bytes;
    print_string (run_java ~dir ~classname:"Relax"));
  [%expect {| widened-goto |}]
