type global_field_value =
  | Gv_int of int
  | Gv_string of string
  | Gv_float of float
  | Gv_block of int * global_field_value list

type global_view =
  | G_string of string
  | G_float of float
  | G_block of int * global_field_value list
  | G_unsupported

let rec classify_field (f : Obj.t) =
  if Obj.is_block f
  then (
    if Obj.tag f = Obj.string_tag
    then Some (Gv_string (Obj.magic f : string))
    else if Obj.tag f = Obj.double_tag
    then Some (Gv_float (Obj.magic f : float))
    else if Obj.tag f < Obj.no_scan_tag
    then (
      let size = Obj.size f in
      let rec gather i acc =
        if i >= size
        then Some (List.rev acc)
        else
          match classify_field (Obj.field f i) with
          | Some fv -> gather (i + 1) (fv :: acc)
          | None -> None
      in
      match gather 0 [] with
      | None -> None
      | Some fields -> Some (Gv_block (Obj.tag f, fields)))
    else None)
  else Some (Gv_int (Obj.magic f : int))

let inspect_global (globals : Obj.t array) n =
  if n < 0 || n >= Array.length globals
  then
    failwith (Printf.sprintf "java_of_ocaml: global index %d out of bounds" n);
  let v = globals.(n) in
  if not (Obj.is_block v)
  then G_unsupported
  else if Obj.tag v = Obj.string_tag
  then G_string (Obj.magic v : string)
  else if Obj.tag v = Obj.double_tag
  then G_float (Obj.magic v : float)
  else if Obj.tag v < Obj.no_scan_tag
  then (
    let size = Obj.size v in
    let rec gather i acc =
      if i >= size
      then Some (List.rev acc)
      else
        match classify_field (Obj.field v i) with
        | Some fv -> gather (i + 1) (fv :: acc)
        | None -> None
    in
    match gather 0 [] with
    | None -> G_unsupported
    | Some fields -> G_block (Obj.tag v, fields))
  else G_unsupported
