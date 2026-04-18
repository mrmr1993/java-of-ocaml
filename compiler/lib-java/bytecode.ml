type t =
  { code : int array
  ; prims : string array
  ; globals : Obj.t array
  }

module Op = struct
  let getglobal = 53
  let pushgetglobal = 54
  let c_call1 = 93
  let stop = 143
end

(* OCaml bumps the trailer magic on every bytecode-format change. We accept
   any "Caml1999X..." magic: the layout described below is stable across the
   bumps we care about (4.x through 5.3+); incompatible layout changes would
   anyway manifest as decoding failures further down. *)
let magic_prefix = "Caml1999X"

let read_exe path =
  let ic = open_in_bin path in
  let total = in_channel_length ic in
  (* Trailer layout (last 16 bytes): [num_sections:u32 BE][magic:12 bytes].
     Before that: num_sections entries of [name:4][len:u32 BE].
     Sections themselves come before the TOC, in file order, starting after
     any optional shebang line. *)
  seek_in ic (total - 16);
  let num_sections = input_binary_int ic in
  let read_magic = really_input_string ic 12 in
  if not (String.length read_magic = 12
          && String.sub read_magic 0 (String.length magic_prefix)
             = magic_prefix)
  then failwith (Printf.sprintf "bytecode: bad magic %S" read_magic);
  let toc_pos = total - 16 - (8 * num_sections) in
  seek_in ic toc_pos;
  let toc =
    Array.init num_sections (fun _ ->
      let name = really_input_string ic 4 in
      let len = input_binary_int ic in
      name, len)
  in
  let total_section_len = Array.fold_left (fun acc (_, l) -> acc + l) 0 toc in
  let first_pos = toc_pos - total_section_len in
  let offsets =
    let p = ref first_pos in
    Array.map
      (fun (name, len) ->
        let off = !p in
        p := !p + len;
        name, off, len)
      toc
  in
  let find_section name =
    let result = ref None in
    Array.iter
      (fun (n, off, len) -> if n = name then result := Some (off, len))
      offsets;
    !result
  in
  let code =
    match find_section "CODE" with
    | None -> failwith "bytecode: missing CODE section"
    | Some (off, len) ->
      if len mod 4 <> 0
      then failwith "bytecode: CODE section length not a multiple of 4";
      seek_in ic off;
      let n = len / 4 in
      (* OCaml bytecode stores each instruction word as a native int32 in
         platform-endian order. On little-endian hosts that means we read the
         raw bytes and unpack as signed LE int32. We use [Bytes.get_int32_le]. *)
      let buf = Bytes.create len in
      really_input ic buf 0 len;
      Array.init n (fun i ->
        Int32.to_int (Bytes.get_int32_le buf (i * 4)))
  in
  let prims =
    match find_section "PRIM" with
    | None -> [||]
    | Some (off, len) ->
      seek_in ic off;
      let raw = really_input_string ic len in
      (* The PRIM section is a sequence of null-terminated primitive names. *)
      let parts = String.split_on_char '\000' raw in
      let parts =
        match List.rev parts with
        | "" :: rest -> List.rev rest
        | _ -> parts
      in
      Array.of_list parts
  in
  let globals =
    match find_section "DATA" with
    | None -> [||]
    | Some (off, _len) ->
      seek_in ic off;
      (Marshal.from_channel ic : Obj.t array)
  in
  close_in ic;
  { code; prims; globals }

let prim_index t name =
  let n = Array.length t.prims in
  let rec loop i =
    if i >= n then None
    else if t.prims.(i) = name then Some i
    else loop (i + 1)
  in
  loop 0
