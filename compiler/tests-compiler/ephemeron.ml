(* Ephemeron / weak-ref primitives. The JVM runtime's [Ephemeron]
   class wraps [java.lang.ref.WeakReference] so key slots can be
   collected independently; our tests focus on the deterministic
   non-GC-dependent behaviour (set / get / check / unset / blit),
   which is what Base's module init actually exercises. *)

open Util

let%expect_test "Ephemeron.create then get on unset slot returns None" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let e = Obj.Ephemeron.create 3 in
         match Obj.Ephemeron.get_key e 1 with
         | None -> caml_java_print_int 0
         | Some _ -> caml_java_print_int 1 |};
  [%expect {| 0 |}]

let%expect_test "Ephemeron.set_key + get_key round-trips" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let e = Obj.Ephemeron.create 3 in
         Obj.Ephemeron.set_key e 0 (Obj.repr 42);
         Obj.Ephemeron.set_key e 2 (Obj.repr 99);
         (match Obj.Ephemeron.get_key e 0 with
          | Some v -> caml_java_print_int (Obj.obj v)
          | None -> caml_java_print_int (-1));
         (match Obj.Ephemeron.get_key e 1 with
          | Some _ -> caml_java_print_int 1
          | None -> caml_java_print_int 0);
         (match Obj.Ephemeron.get_key e 2 with
          | Some v -> caml_java_print_int (Obj.obj v)
          | None -> caml_java_print_int (-1)) |};
  [%expect {|
    42
    0
    99 |}]

let%expect_test "Ephemeron.check_key distinguishes set / unset slots" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let b x = if x then 1 else 0
       let () =
         let e = Obj.Ephemeron.create 2 in
         caml_java_print_int (b (Obj.Ephemeron.check_key e 0));
         Obj.Ephemeron.set_key e 0 (Obj.repr "hello");
         caml_java_print_int (b (Obj.Ephemeron.check_key e 0));
         Obj.Ephemeron.unset_key e 0;
         caml_java_print_int (b (Obj.Ephemeron.check_key e 0)) |};
  [%expect {|
    0
    1
    0 |}]

let%expect_test "Ephemeron.set_data + get_data + unset_data" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let e = Obj.Ephemeron.create 1 in
         (* No keys set → data still clears under our approximation when
            any unset key observer runs, but set_data with all-unset keys
            is semantically "set + data is live". We set a key first to
            keep the data reachable. *)
         Obj.Ephemeron.set_key e 0 (Obj.repr 1);
         Obj.Ephemeron.set_data e (Obj.repr 77);
         (match Obj.Ephemeron.get_data e with
          | Some v -> caml_java_print_int (Obj.obj v)
          | None -> caml_java_print_int (-1));
         Obj.Ephemeron.unset_data e;
         (match Obj.Ephemeron.get_data e with
          | Some _ -> caml_java_print_int 1
          | None -> caml_java_print_int 0) |};
  [%expect {|
    77
    0 |}]

let%expect_test "Weak.t: create / set / get / check" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let b x = if x then 1 else 0
       let () =
         let w : int Weak.t = Weak.create 3 in
         caml_java_print_int (b (Weak.check w 0));
         Weak.set w 0 (Some 123);
         Weak.set w 2 (Some 456);
         caml_java_print_int (b (Weak.check w 0));
         (match Weak.get w 0 with
          | Some v -> caml_java_print_int v
          | None -> caml_java_print_int (-1));
         caml_java_print_int (b (Weak.check w 1));
         (match Weak.get w 2 with
          | Some v -> caml_java_print_int v
          | None -> caml_java_print_int (-1));
         Weak.set w 0 None;
         caml_java_print_int (b (Weak.check w 0)) |};
  [%expect {|
    0
    1
    123
    0
    456
    0 |}]

let%expect_test "Ephemeron.blit_key copies slots between ephemerons" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = Obj.Ephemeron.create 3 in
         let b = Obj.Ephemeron.create 3 in
         Obj.Ephemeron.set_key a 0 (Obj.repr 10);
         Obj.Ephemeron.set_key a 1 (Obj.repr 20);
         Obj.Ephemeron.set_key a 2 (Obj.repr 30);
         Obj.Ephemeron.blit_key a 1 b 0 2;
         (match Obj.Ephemeron.get_key b 0 with
          | Some v -> caml_java_print_int (Obj.obj v)
          | None -> caml_java_print_int (-1));
         (match Obj.Ephemeron.get_key b 1 with
          | Some v -> caml_java_print_int (Obj.obj v)
          | None -> caml_java_print_int (-1));
         (match Obj.Ephemeron.get_key b 2 with
          | Some _ -> caml_java_print_int 1
          | None -> caml_java_print_int 0) |};
  [%expect {|
    20
    30
    0 |}]
