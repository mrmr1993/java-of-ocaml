(* End-to-end tests for the ppx_java syntax sugar.

   The PPX rewrites:
     obj ## meth a1 a2         → Java.Unsafe.meth_call obj "meth" ...
     [%java.new "C" a1 ...]    → Java.Unsafe.new_obj "C" ...
     [%java.static "C" "m" a1] → Java.Unsafe.static_meth_call ...
     [%java.get obj "field"]   → Java.Unsafe.get obj "field"
     [%java.set obj "field" v] → Java.Unsafe.set obj "field" v

   All expansions go through the reflective [JavaFFI] runtime helpers.
   Tests invoke the PPX by passing [-ppx] to [ocamlc]; [Java.Unsafe]
   is provided as a local in-file module so tests don't depend on
   findlib resolving [java_of_ocaml.runtime]. *)

open Util

let ppx_exe =
  Filename.concat java_of_ocaml_root "ppx/ppx_java/bin/main.exe"

let ocaml_flags_ppx = [ "-ppx"; "\"" ^ ppx_exe ^ " --as-ppx\"" ]

(* A lightweight inline [Java.Unsafe] module matching the one in
   lib-java-runtime, so tests are self-contained. The external prim
   names target [JavaFFI] directly. *)
let unsafe_prelude =
  {|
    module Java = struct
      module Unsafe = struct
        external meth_call : 'a -> string -> Obj.t array -> 'b
          = "java:static:JavaFFI:callVirtual:(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;"
        external static_meth_call : string -> string -> Obj.t array -> 'b
          = "java:static:JavaFFI:callStatic:(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;"
        external new_obj : string -> Obj.t array -> 'a
          = "java:static:JavaFFI:newInstance:(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;"
        external get : 'a -> string -> 'b
          = "java:static:JavaFFI:getField:(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;"
        external set : 'a -> string -> 'b -> unit
          = "java:static:JavaFFI:setField:(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V"
        external inject : 'a -> Obj.t = "%identity"
      end
    end
    external caml_java_print_int : int -> unit = "caml_java_print_int"
  |}

let%expect_test "ppx: [%java.static \"C\" \"m\" args]" =
  compile_and_run
    ~ocaml_flags:ocaml_flags_ppx
    (unsafe_prelude ^ {|
      let () =
        let r = [%java.static "java/lang/Integer" "parseInt" "42"] in
        caml_java_print_int (Obj.obj r)
    |});
  [%expect {| 42 |}]

let%expect_test "ppx: obj ## method args via [%java.new] result" =
  compile_and_run
    ~ocaml_flags:ocaml_flags_ppx
    (unsafe_prelude ^ {|
      let () =
        let xs = [%java.new "java.util.ArrayList"] in
        let (_ : Obj.t) = xs ## add 1 in
        let (_ : Obj.t) = xs ## add 2 in
        let (_ : Obj.t) = xs ## add 3 in
        let n : Obj.t = xs ## size in
        caml_java_print_int (Obj.obj n)
    |});
  [%expect {| 3 |}]
