type prim_handler =
  | P_println_int
  | P_println_string
  | P_array_get
  | P_array_set
  | P_obj_dup
  | P_obj_tag
  | P_obj_block
  | P_obj_with_tag
  | P_fresh_oo_id
  | P_alloc_dummy
  | P_update_dummy

type prim_entry =
  { name : string
  ; handler : prim_handler
  ; seed : bool
  }

let primitives : prim_entry list =
  [ { name = "caml_java_print_endline"; handler = P_println_string; seed = true }
  ; { name = "caml_java_print_int"; handler = P_println_int; seed = true }
  ; { name = "caml_array_get_addr"; handler = P_array_get; seed = true }
  ; { name = "caml_array_set_addr"; handler = P_array_set; seed = true }
  ; { name = "caml_array_unsafe_get"; handler = P_array_get; seed = false }
  ; { name = "caml_array_unsafe_set"; handler = P_array_set; seed = false }
  ; { name = "caml_obj_dup"; handler = P_obj_dup; seed = true }
  ; { name = "caml_obj_tag"; handler = P_obj_tag; seed = false }
  ; { name = "caml_obj_block"; handler = P_obj_block; seed = false }
  ; { name = "caml_obj_with_tag"; handler = P_obj_with_tag; seed = false }
  ; { name = "caml_fresh_oo_id"; handler = P_fresh_oo_id; seed = false }
  ; { name = "caml_alloc_dummy"; handler = P_alloc_dummy; seed = true }
  ; { name = "caml_update_dummy"; handler = P_update_dummy; seed = true }
  ]

type table = (int, string * prim_handler * bool) Hashtbl.t

let find_supported_prims bc =
  let table = Hashtbl.create 4 in
  List.iter
    (fun { name; handler; seed } ->
      match Bytecode.prim_index bc name with
      | Some idx -> Hashtbl.add table idx (name, handler, seed)
      | None -> ())
    primitives;
  table
