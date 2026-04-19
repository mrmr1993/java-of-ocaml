(* [Bytecode.read_cmo] / [Bytecode.read_cma] smoke tests.

   Groundwork for the [from_cmo] / [from_cma] alignment item
   (separate-compilation inputs). This pass only covers the reader —
   IR lowering and linking of relocatable code words remain to be
   written. *)

open Java_of_ocaml_expect_tests_helper

let relocs_summary (u : Java_of_ocaml_compiler.Bytecode.unit_info) =
  let open Java_of_ocaml_compiler.Bytecode in
  List.map
    (fun (r, off) ->
      let tag =
        match r with
        | Reloc_literal _ -> "literal"
        | Reloc_getcompunit c -> Printf.sprintf "getcompunit %s" c
        | Reloc_getpredef p -> Printf.sprintf "getpredef %s" p
        | Reloc_setcompunit c -> Printf.sprintf "setcompunit %s" c
        | Reloc_primitive p -> Printf.sprintf "primitive %s" p
      in
      Printf.sprintf "@%d %s" off tag)
    u.cu_reloc

let%expect_test "read_cmo extracts code, prims, and relocs" =
  Util.with_temp_dir ~f:(fun () ->
      let cmo =
        Util.compile_ocaml_to_cmo
          Util.Filetype.(ocaml_file_of_path "sample.ml"
                         |> fun _ ->
                         let p = "sample.ml" in
                         let oc = open_out p in
                         output_string
                           oc
                           "let message = \"hi\"\n\
                            let length = String.length message\n\
                            let () = print_int length; print_newline ()\n";
                         close_out oc;
                         ocaml_file_of_path p)
      in
      let u =
        Java_of_ocaml_compiler.Bytecode.read_cmo
          (Util.Filetype.path_of_cmo_file cmo)
      in
      let open Java_of_ocaml_compiler.Bytecode in
      Printf.printf
        "name=%s code_words=%d prims=%d relocs=%d imports=%d\n"
        u.cu_name
        (Array.length u.cu_code)
        (Array.length u.cu_prims)
        (List.length u.cu_reloc)
        (List.length u.cu_imports);
      List.iter
        (fun (n, crc) ->
          Printf.printf
            "import %s crc=%s\n"
            n
            (match crc with
             | None -> "-"
             | Some _ -> "<hash>"))
        (List.sort compare u.cu_imports);
      (* Reloc order is stable (compiler-assigned). Print a few kinds
         to show they parse. *)
      let kinds =
        List.sort_uniq
          compare
          (List.map
             (fun (r, _) ->
               match r with
               | Reloc_literal _ -> "literal"
               | Reloc_getcompunit _ -> "getcompunit"
               | Reloc_getpredef _ -> "getpredef"
               | Reloc_setcompunit _ -> "setcompunit"
               | Reloc_primitive _ -> "primitive")
             u.cu_reloc)
      in
      Printf.printf "reloc_kinds=[%s]\n" (String.concat ";" kinds));
  [%expect
    {|
    name=Sample code_words=24 prims=0 relocs=5 imports=7
    import CamlinternalFormatBasics crc=<hash>
    import Sample crc=<hash>
    import Stdlib crc=<hash>
    import Stdlib__Either crc=<hash>
    import Stdlib__Seq crc=<hash>
    import Stdlib__String crc=<hash>
    import Stdlib__Uchar crc=<hash>
    reloc_kinds=[getcompunit;literal;primitive;setcompunit]
    |}]

let%expect_test "read_file magic-number probe routes correctly" =
  Util.with_temp_dir ~f:(fun () ->
      let make path contents =
        let oc = open_out path in
        output_string oc contents;
        close_out oc;
        path
      in
      let src =
        make
          "probe.ml"
          "let () = print_endline \"hi\"\n"
      in
      let cmo =
        Util.compile_ocaml_to_cmo
          (Util.Filetype.ocaml_file_of_path src)
      in
      let bc =
        Util.compile_ocaml_to_bc
          (Util.Filetype.ocaml_file_of_path src)
      in
      let classify path =
        match Java_of_ocaml_compiler.Bytecode.read_file path with
        | Exe _ -> "exe"
        | Cmo _ -> "cmo"
        | Cma _ -> "cma"
      in
      Printf.printf
        "cmo->%s bc->%s\n"
        (classify (Util.Filetype.path_of_cmo_file cmo))
        (classify (Util.Filetype.path_of_bc_file bc)));
  [%expect {| cmo->cmo bc->exe |}]
