let primitive_name = "caml_java_print_endline"

let string_of_global (globals : Obj.t array) n =
  if n < 0 || n >= Array.length globals
  then
    failwith
      (Printf.sprintf "java_of_ocaml: global index %d out of bounds" n);
  let v = globals.(n) in
  if not (Obj.is_block v)
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: global %d is an int, not a string (immediate arg \
          forms aren't supported yet)"
         n);
  if Obj.tag v <> Obj.string_tag
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: global %d has tag %d, expected a string"
         n
         (Obj.tag v));
  (Obj.magic v : string)

(* Walk CODE looking for [C_CALL1 prim_idx] where [prim_idx] matches our
   primitive. The preceding two words must be a global load — either
   [GETGLOBAL idx] (first call of a sequence) or [PUSHGETGLOBAL idx] (any
   subsequent call, where the previous call's return value gets pushed before
   loading the next string). Returns the loaded strings in program order. *)
let extract_messages (bc : Bytecode.t) =
  match Bytecode.prim_index bc primitive_name with
  | None ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: bytecode does not reference %s. This Phase 0 \
          compiler only knows how to compile programs that call %s."
         primitive_name
         primitive_name)
  | Some prim_idx ->
    let code = bc.code in
    let n = Array.length code in
    let rec loop i acc =
      if i + 1 >= n
      then List.rev acc
      else if code.(i) = Bytecode.Op.c_call1 && code.(i + 1) = prim_idx
      then
        if i < 2
        then
          failwith
            "java_of_ocaml: C_CALL1 at start of code — expected a global \
             load before it"
        else
          let prev = code.(i - 2) in
          if prev = Bytecode.Op.getglobal
             || prev = Bytecode.Op.pushgetglobal
          then
            let msg = string_of_global bc.globals code.(i - 1) in
            loop (i + 2) (msg :: acc)
          else
            failwith
              (Printf.sprintf
                 "java_of_ocaml: %s call at word %d is preceded by opcode \
                  %d; only GETGLOBAL (%d) / PUSHGETGLOBAL (%d) are \
                  supported as the string source"
                 primitive_name
                 i
                 prev
                 Bytecode.Op.getglobal
                 Bytecode.Op.pushgetglobal)
      else loop (i + 1) acc
    in
    loop 0 []

let compile ~bc ~out_dir =
  let parsed = Bytecode.read_exe bc in
  let messages = extract_messages parsed in
  if messages = []
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: no calls to %s found in the bytecode"
         primitive_name);
  let class_bytes = Jvm.emit_main_class ~messages in
  let out_path = Filename.concat out_dir "Main.class" in
  let oc = open_out_bin out_path in
  output_string oc class_bytes;
  close_out oc
