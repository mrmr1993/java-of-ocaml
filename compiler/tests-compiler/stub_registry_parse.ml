(* Unit tests for [Stub_registry.load_string] — happy path, full
   record, weakdef collision, malformed input. *)

module SR = Java_of_ocaml_compiler.Stub_registry

let print_stub (s : SR.stub) =
  Printf.printf
    "%s -> %s.%s  desc=%s arity=%d%s\n"
    s.prim_name
    s.class_name
    s.method_name
    s.descriptor
    s.arity
    (if s.weakdef then " weakdef" else "")

let load s =
  SR.load_string ~source_path:"<test>" s |> SR.all_stubs

let%expect_test "shorthand entry" =
  let r = load {|{ "caml_foo": "Foo.bar" }|} in
  List.iter print_stub r;
  [%expect {| caml_foo -> Foo.bar  desc=()Ljava/lang/Object; arity=0 |}]
;;

let%expect_test "full record with descriptor" =
  let r =
    load
      {|{ "caml_add": { "target": "M.add",
                        "descriptor": "(JJ)J" } }|}
  in
  List.iter print_stub r;
  [%expect {| caml_add -> M.add  desc=(JJ)J arity=2 |}]
;;

let%expect_test "weakdef flag" =
  let r = load {|{ "p": { "target": "X.y", "weakdef": true } }|} in
  List.iter print_stub r;
  [%expect {| p -> X.y  desc=()Ljava/lang/Object; arity=0 weakdef |}]
;;

let%expect_test "dotted class name normalises to slash" =
  let r = load {|{ "p": "a.b.Cls.method" }|} in
  List.iter print_stub r;
  [%expect {| p -> a/b/Cls.method  desc=()Ljava/lang/Object; arity=0 |}]
;;

let%expect_test "malformed shorthand (no dot)" =
  (try
     let _ = load {|{ "p": "NoDotHere" }|} in
     print_endline "unexpectedly succeeded"
   with Failure m -> print_endline m);
  [%expect
    {| stub_registry (<test>): target "NoDotHere" must be ClassName.methodName |}]
;;

let%expect_test "malformed top level" =
  (try
     let _ = load {|["list", "not", "object"]|} in
     print_endline "unexpectedly succeeded"
   with Failure m -> print_endline m);
  [%expect {| stub_registry: <test>: top-level must be a JSON object |}]
;;

let%expect_test "unknown key warns but accepts" =
  let r =
    load {|{ "p": { "target": "X.y", "future_flag": true } }|}
  in
  List.iter print_stub r;
  [%expect
    {|
    [stub_registry] warning (<test>): unknown key "future_flag" on p
    p -> X.y  desc=()Ljava/lang/Object; arity=0
    |}]
;;
