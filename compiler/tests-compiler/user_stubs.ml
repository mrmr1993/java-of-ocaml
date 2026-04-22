(* End-to-end test for the --stub-manifest mechanism.

   Declare an external primitive on the OCaml side, drop a Java
   file + a JSON manifest, and confirm the compiler picks up the
   stub and the resulting program prints the stub's return. *)

let write_file path s =
  let oc = open_out path in
  output_string oc s;
  close_out oc

let%expect_test "stub-manifest: primitive routes through Java" =
  (* Stage the stub sources in a stable subdir that persists across
     [compile_and_run]'s own temp-dir (which switches cwd). Using an
     absolute path in [--stub-manifest] keeps the lookup robust. *)
  let stub_dir =
    Filename.concat (Filename.get_temp_dir_name ()) "jofo_user_stubs_test"
  in
  (try Sys.mkdir stub_dir 0o755 with Sys_error _ -> ());
  write_file
    (Filename.concat stub_dir "MyStubs.java")
    {|public final class MyStubs {
  private MyStubs() {}

  // OCaml-side: external my_negate : int -> int = "my_negate"
  public static long my_negate(long x) { return -x; }
}
|};
  write_file
    (Filename.concat stub_dir "stubs.json")
    {|{
  "my_negate": {
    "target": "MyStubs.my_negate",
    "descriptor": "(J)J"
  }
}
|};
  let manifest_path = Filename.concat stub_dir "stubs.json" in
  let ocaml_src = {|
external my_negate : int -> int = "my_negate"
let () = Printf.printf "%d\n" (my_negate 42)
|} in
  Util.compile_and_run
    ~flags:[ "--stub-manifest"; manifest_path ]
    ocaml_src;
  [%expect {| -42 |}]
;;
