type global_field_value =
  | Gv_int of int
  | Gv_string of string
  | Gv_float of float
  | Gv_int64 of int64
      (** Custom_tag size-2 blocks (int32/int64/nativeint). We read the
          payload as int64 — on 64-bit OCaml all three encode their value
          in field 1 as a raw word. Emitted as a [java.lang.Long] box so
          [as_int] can truncate to JVM int via [longValue] + [l2i]. *)
  | Gv_block of int * global_field_value list
  | Gv_null
      (** Placeholder for a field that [classify_field] can't
          represent (closures, foreign custom blocks, etc.). Emitted as
          [null] so the surrounding Block is still materialised;
          a later SETGLOBAL / Field write typically overwrites it
          before anything reads. *)

type global_view =
  | G_int of int
  | G_string of string
  | G_float of float
  | G_int64 of int64
  | G_block of int * global_field_value list
  | G_unsupported

(* Always returns Some _. Unrecognised values become [Gv_null] so the
   enclosing Block still materialises with that field at null; callers
   rely on a later SETGLOBAL or Field write filling it in. *)
let rec classify_field (f : Obj.t) =
  if Obj.is_block f
  then (
    if Obj.tag f = Obj.string_tag
    then Some (Gv_string (Obj.magic f : string))
    else if Obj.tag f = Obj.double_tag
    then Some (Gv_float (Obj.magic f : float))
    else if Obj.tag f = Obj.custom_tag && Obj.size f >= 2
    then Some (Gv_int64 (Obj.magic f : int64))
    else if Obj.tag f < Obj.no_scan_tag
    then (
      let size = Obj.size f in
      let rec gather i acc =
        if i >= size
        then List.rev acc
        else
          let fv =
            match classify_field (Obj.field f i) with
            | Some fv -> fv
            | None -> Gv_null
          in
          gather (i + 1) (fv :: acc)
      in
      Some (Gv_block (Obj.tag f, gather 0 [])))
    else Some Gv_null)
  else Some (Gv_int (Obj.magic f : int))

let inspect_global (globals : Obj.t array) n =
  if n < 0 || n >= Array.length globals
  then
    failwith (Printf.sprintf "java_of_ocaml: global index %d out of bounds" n);
  let v = globals.(n) in
  if not (Obj.is_block v)
  then G_int (Obj.magic v : int)
  else if Obj.tag v = Obj.string_tag
  then G_string (Obj.magic v : string)
  else if Obj.tag v = Obj.double_tag
  then G_float (Obj.magic v : float)
  else if Obj.tag v = Obj.custom_tag && Obj.size v >= 2
  then G_int64 (Obj.magic v : int64)
  else if Obj.tag v < Obj.no_scan_tag
  then (
    let size = Obj.size v in
    let rec gather i acc =
      if i >= size
      then List.rev acc
      else
        let fv =
          match classify_field (Obj.field v i) with
          | Some fv -> fv
          | None -> Gv_null
        in
        gather (i + 1) (fv :: acc)
    in
    G_block (Obj.tag v, gather 0 []))
  else G_unsupported
