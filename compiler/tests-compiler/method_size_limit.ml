(* 64 KB method-size limit: the JVM [Code] attribute's code_length
   field is capped at 65535 bytes (JVMS §4.7.3). The class-file
   assembler raises [Method_too_large] rather than emit a class the
   JVM would reject. Exercise the detection by synthesising a method
   body past the limit via the [Jvm.Code] API — same approach as
   [branch_relaxation.ml], since producing a >65 KB method through
   the OCaml pipeline requires heavy ppx expansion we don't have on
   hand. *)

open Java_of_ocaml_compiler

(* Each iteration emits 2 bytes ([iconst_0; pop], 0x03 0x57). *)
let emit_padding code ~bytes =
  let n = (bytes + 1) / 2 in
  for _ = 1 to n do
    Jvm.Code.ldc_int code 0;
    Jvm.Code.pop_top code
  done

let build_oversized_class ~body_bytes =
  let cp = Jvm.Cp.create () in
  let code = Jvm.Code.create cp in
  emit_padding code ~bytes:body_bytes;
  Jvm.Code.return_void code;
  Jvm.assemble_class
    ~class_name:"Huge"
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

let%expect_test "a method at exactly the 65535-byte limit assembles" =
  let bytes = build_oversized_class ~body_bytes:65534 in
  (* [return_void] adds 1 byte → code_length = 65535, the cap. *)
  Printf.printf "class_bytes=%d\n" (String.length bytes);
  [%expect {| class_bytes=65656 |}]

let%expect_test "a method past 65535 bytes raises Method_too_large" =
  (match build_oversized_class ~body_bytes:65536 with
   | _ -> print_endline "no exception"
   | exception Jvm_class_file.Method_too_large { class_name; method_name; size } ->
     Printf.printf
       "Method_too_large: %s.%s size=%d\n"
       class_name
       method_name
       size);
  [%expect {| Method_too_large: Huge.main size=65537 |}]
