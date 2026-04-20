module Jooc = Java_of_ocaml_compiler

(* Build a minimal [Code.program] that calls one extern primitive
   and returns the result, emit it via [Jvm_generate], and return
   either [Ok (estimate, actual)] or [Error msg] if the emitter
   bailed. The per-primitive cost test uses this to cross-check
   [Code_cost.extern_cost] against what [Jvm_generate] actually
   emits.

   [emit_prim] dispatches C primitives through an [Extern
   "ccall_<idx>"] indirection; the real name is resolved via the
   [prim_name] callback (populated from the bytecode's PRIM
   section in a real compile). We fake that: primitives whose name
   matches a direct-dispatch [emit_prim] case (e.g. [alloc_block],
   [get_global]) keep their literal name; everything else comes in
   as [ccall_0] with [prim_name 0] returning the real name. *)
let direct_extern_names =
  [ "alloc_block"
  ; "get_global"
  ; "get_global_field"
  ; "set_global"
  ]

let measure_extern_cost
      ?(prefix_extras = [])
      ?(extras = [])
      ~nargs
      name
  =
  let open Jooc.Code in
  let args = List.init nargs (fun _ -> Var.fresh ()) in
  let pa_args = List.map (fun v -> Pv v) args in
  let all_args = prefix_extras @ pa_args @ extras in
  let result = Var.fresh () in
  let is_direct = List.mem name direct_extern_names in
  let ir_name = if is_direct then name else "ccall_0" in
  let body = [| Let (result, Prim (Extern ir_name, all_args)) |] in
  let block = { params = args; body; branch = Return result } in
  let prog =
    { start = 0
    ; blocks = Addr.Map.add 0 block Addr.Map.empty
    ; free_pc = 1
    }
  in
  let cp = Jooc.Jvm.Cp.create () in
  let code = Jooc.Jvm.Code.create cp in
  Jooc.Jvm.Code.set_min_locals code (List.length args + 1);
  let typing = Jooc.Jvm_typing.infer prog in
  try
    Jooc.Jvm_generate.emit_program
      ~code
      ~typing
      ~name_of_body:(fun _ -> raise Not_found)
      ~fn_info_of_body:(fun _ -> None)
      ~prim_name:(fun i -> if i = 0 then name else raise Not_found)
      ~arg_vars:args
      ~is_static:true
      prog;
    let actual = Jooc.Jvm.Code.resolved_size code in
    (* Ideal estimate: what [Code_cost.program] would return if
       [extern_cost] for this name were applied end-to-end. The
       arithmetic mirrors what [Code_cost.program] actually computes
       for a 1-block / 1-instr / Return program: entry_overhead +
       Let instr (6 + prim_cost + per-arg cost) + Return (8). *)
    let per_arg_cost pa =
      match pa with
      | Pv _ -> 2
      | Pc (Int n) ->
        if n >= -1 && n <= 5 then 1
        else if n >= -128 && n <= 127 then 2
        else 3
      | Pc _ -> 5
    in
    let arg_bytes =
      List.fold_left (fun a pa -> a + per_arg_cost pa) 0 all_args
    in
    let entry_overhead = 2 * nargs in
    let ideal =
      entry_overhead
      + (3 + Jooc.Code_cost.extern_cost name + arg_bytes)
      + 3
    in
    Ok (ideal, actual)
  with
  | Jooc.Jvm_generate.Unsupported msg -> Error ("Unsupported: " ^ msg)
  | Failure msg -> Error ("Failure: " ^ msg)

let exe =
  match Sys.os_type with
  | "Cygwin" | "Win32" -> fun x -> x ^ ".exe"
  | "Unix" | _ -> fun x -> x

let ocamlc = try Sys.getenv "OCAMLC" with Not_found -> exe "ocamlc"

let ocamlrun = try Sys.getenv "OCAMLRUN" with Not_found -> exe "ocamlrun"

let java = try Sys.getenv "JAVA" with Not_found -> exe "java"

let java_of_ocaml_root =
  try
    let dir = Sys.getenv "PROJECT_ROOT" in
    if Filename.is_relative dir then Filename.concat (Sys.getcwd ()) dir else dir
  with Not_found -> (
    let regex_text = "_build" in
    let regex = Str.regexp regex_text in
    match Sys.getcwd () |> Str.split regex with
    | left :: _ :: _ -> Filename.concat (Filename.concat left regex_text) "default"
    | _ -> failwith "unable to find project root")

let prng = lazy (Random.State.make_self_init ())

let temp_file_name temp_dir prefix suffix =
  let rnd = Random.State.bits (Lazy.force prng) land 0xFFFFFF in
  Filename.concat temp_dir (Printf.sprintf "%s%06x%s" prefix rnd suffix)

let remove_dir =
  let rec loop_files dir handle =
    match Unix.readdir handle with
    | ".." | "." -> loop_files dir handle
    | f ->
        let dir_or_file = Filename.concat dir f in
        if Sys.is_directory dir_or_file
        then remove_dir dir_or_file
        else Sys.remove dir_or_file;
        loop_files dir handle
    | exception End_of_file -> ()
  and remove_dir dir =
    let handle = Unix.opendir dir in
    loop_files dir handle;
    Unix.closedir handle;
    Unix.rmdir dir
  in
  remove_dir

let with_temp_dir ~f =
  let old_cwd = Sys.getcwd () in
  let temp = Filename.get_temp_dir_name () in
  let dir = temp_file_name temp "java-of-ocaml-test" "" in
  Unix.mkdir dir 0o700;
  Sys.chdir dir;
  let x = f () in
  Sys.chdir old_cwd;
  remove_dir dir;
  x

module Filetype : Filetype_intf.S = struct
  type ocaml_text = string

  type ocaml_file = string

  type cmo_file = string

  type bc_file = string

  type class_file = string

  type jar_file = string

  let read_file file =
    let ic = open_in_bin file in
    let n = in_channel_length ic in
    let s = Bytes.create n in
    really_input ic s 0 n;
    close_in ic;
    Bytes.unsafe_to_string s

  let write_file name contents =
    let channel = open_out_bin name in
    Printf.fprintf channel "%s" contents;
    close_out channel

  let read_ocaml = read_file

  let write_ocaml ~name content =
    write_file name content;
    name

  let id x = x

  let ocaml_text_of_string = id

  let string_of_ocaml_text = id

  let path_of_ocaml_file = id

  let path_of_cmo_file = id

  let path_of_bc_file = id

  let path_of_class_file = id

  let path_of_jar_file = id

  let ocaml_file_of_path = id

  let cmo_file_of_path = id

  let bc_file_of_path = id

  let class_file_of_path = id

  let jar_file_of_path = id
end

let channel_to_string c_in =
  let good_round_number = 1024 in
  let buffer = Buffer.create good_round_number in
  let rec loop () =
    Buffer.add_channel buffer c_in good_round_number;
    loop ()
  in
  (try loop () with End_of_file -> ());
  Buffer.contents buffer

let exec_to_string_exn ?input ~fail ~cmd () =
  let env = Unix.environment () in
  let proc_result_ok std_out =
    let open Unix in
    function
    | WEXITED 0 -> std_out
    | WEXITED i ->
        Format.sprintf "%s\nprocess exited with error code %d\n %s\n" std_out i cmd
    | WSIGNALED i ->
        Format.sprintf "%s\nprocess signaled with signal number %d\n %s\n" std_out i cmd
    | WSTOPPED i ->
        Format.sprintf "%s\nprocess stopped with signal number %d\n %s\n" std_out i cmd
  in
  let ((proc_in, oc, proc_err) as proc_full) = Unix.open_process_full cmd env in
  (match input with
  | None -> ()
  | Some s ->
      output_string oc s;
      close_out oc);
  let results = channel_to_string proc_in in
  let results' = channel_to_string proc_err in
  let exit_status = Unix.close_process_full proc_full in
  let res =
    proc_result_ok
      (String.concat
         "\n"
         (List.filter
            (function
              | "" -> false
              | _ -> true)
            [ results'; results ]))
      exit_status
  in
  match exit_status with
  | WEXITED n when n <> 0 && fail ->
      print_endline res;
      raise_notrace (Failure "non-zero exit code")
  | _ -> res

let swap_extension filename ~ext =
  Format.sprintf "%s.%s" (Filename.remove_extension filename) ext

let compile_ocaml_to_cmo ?(debug = true) file =
  let file = Filetype.path_of_ocaml_file file in
  let out_file = swap_extension file ~ext:"cmo" in
  let (stdout : string) =
    exec_to_string_exn
      ~fail:true
      ~cmd:
        (Format.sprintf
           "%s -c %s %s -o %s"
           ocamlc
           (if debug then "-g" else "")
           file
           out_file)
      ()
  in
  print_string stdout;
  Filetype.cmo_file_of_path out_file

let compile_ocaml_to_bc ?(debug = true) ?(unix = false) ?(ocaml_flags = []) file =
  let file = Filetype.path_of_ocaml_file file in
  let out_file = swap_extension file ~ext:"bc" in
  let (stdout : string) =
    exec_to_string_exn
      ~fail:true
      ~cmd:
        (Format.sprintf
           "%s -no-check-prims %s %s %s %s -o %s"
           ocamlc
           (if debug then "-g" else "")
           (if unix then "-I +unix unix.cma" else "")
           (String.concat " " ocaml_flags)
           file
           out_file)
      ()
  in
  print_string stdout;
  Filetype.bc_file_of_path out_file

let compile_lib list name =
  let out_file = swap_extension name ~ext:"cma" in
  let (stdout : string) =
    exec_to_string_exn
      ~fail:true
      ~cmd:
        (Format.sprintf
           "%s -g -a %s -o %s"
           ocamlc
           (String.concat " " (List.map Filetype.path_of_cmo_file list))
           out_file)
      ()
  in
  print_string stdout;
  Filetype.cmo_file_of_path out_file

let compile_bc_to_class ?(flags = []) file =
  let file_path = Filetype.path_of_bc_file file in
  let out_dir = Filename.dirname file_path in
  let extra_args = String.concat " " flags in
  let compiler_location =
    Filename.concat java_of_ocaml_root "compiler/bin-java_of_ocaml/java_of_ocaml.exe"
  in
  let cmd =
    Format.sprintf "%s %s %s -o %s" compiler_location extra_args file_path out_dir
  in
  let stdout = exec_to_string_exn ~fail:true ~cmd () in
  print_string stdout;
  Filetype.class_file_of_path (Filename.concat out_dir "Main.class")

let compile_cmo_to_class ?(flags = []) file =
  let file_path = Filetype.path_of_cmo_file file in
  let out_dir = Filename.dirname file_path in
  let extra_args = String.concat " " flags in
  let compiler_location =
    Filename.concat java_of_ocaml_root "compiler/bin-java_of_ocaml/java_of_ocaml.exe"
  in
  let cmd =
    Format.sprintf "%s %s %s -o %s" compiler_location extra_args file_path out_dir
  in
  let stdout = exec_to_string_exn ~fail:true ~cmd () in
  print_string stdout;
  Filetype.class_file_of_path (Filename.concat out_dir "Main.class")

let run_java ?(classpath = []) file =
  let class_path = Filetype.path_of_class_file file in
  let dir = Filename.dirname class_path in
  let classname = Filename.basename class_path |> Filename.remove_extension in
  let cp = String.concat ":" (dir :: classpath) in
  exec_to_string_exn
    ~fail:false
    ~cmd:(Format.sprintf "%s -cp %s %s" java cp classname)
    ()

let run_bytecode file =
  exec_to_string_exn
    ~fail:false
    ~cmd:(Format.sprintf "%s %s" ocamlrun (Filetype.path_of_bc_file file))
    ()

let compile_and_run_bytecode ?unix s =
  with_temp_dir ~f:(fun () ->
      s
      |> Filetype.ocaml_text_of_string
      |> Filetype.write_ocaml ~name:"test.ml"
      |> compile_ocaml_to_bc ?unix
      |> run_bytecode
      |> print_endline)

let compile_and_run ?(flags = []) ?(ocaml_flags = []) ?debug ?unix s =
  with_temp_dir ~f:(fun () ->
      let bytecode_file =
        s
        |> Filetype.ocaml_text_of_string
        |> Filetype.write_ocaml ~name:"test.ml"
        |> compile_ocaml_to_bc ?debug ?unix ~ocaml_flags
      in
      let class_file = compile_bc_to_class ~flags bytecode_file in
      let output = run_java class_file in
      print_endline output)

let normalize_path s =
  String.map
    (function
      | '\\' -> '/'
      | x -> x)
    s

let javap = try Sys.getenv "JAVAP" with Not_found -> exe "javap"

let javap_class file =
  let path = Filetype.path_of_class_file file in
  let dir = Filename.dirname path in
  let classname = Filename.basename path |> Filename.remove_extension in
  exec_to_string_exn
    ~fail:true
    ~cmd:(Format.sprintf "%s -c -cp %s %s" javap dir classname)
    ()

let javap_class_lines file =
  let path = Filetype.path_of_class_file file in
  let dir = Filename.dirname path in
  let classname = Filename.basename path |> Filename.remove_extension in
  exec_to_string_exn
    ~fail:true
    ~cmd:(Format.sprintf "%s -l -cp %s %s" javap dir classname)
    ()

let compile_and_javap_lines ?(flags = []) ?(ocaml_flags = []) ?debug ?unix s =
  with_temp_dir ~f:(fun () ->
    let bytecode_file =
      s
      |> Filetype.ocaml_text_of_string
      |> Filetype.write_ocaml ~name:"test.ml"
      |> compile_ocaml_to_bc ?debug ?unix ~ocaml_flags
    in
    let class_file = compile_bc_to_class ~flags bytecode_file in
    let listing = javap_class_lines class_file in
    print_endline listing)

let compile_and_javap ?(flags = []) ?(ocaml_flags = []) ?debug ?unix s =
  with_temp_dir ~f:(fun () ->
    let bytecode_file =
      s
      |> Filetype.ocaml_text_of_string
      |> Filetype.write_ocaml ~name:"test.ml"
      |> compile_ocaml_to_bc ?debug ?unix ~ocaml_flags
    in
    let class_file = compile_bc_to_class ~flags bytecode_file in
    let listing = javap_class class_file in
    (* Strip the leading line that names the generated temp dir so the
       output is stable across runs. *)
    let lines = String.split_on_char '\n' listing in
    let lines =
      List.filter
        (fun l ->
          not
            (String.length l > 13 && String.sub l 0 13 = "Compiled from"))
        lines
    in
    print_endline (String.concat "\n" lines))
