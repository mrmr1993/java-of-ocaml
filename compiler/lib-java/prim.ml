type prim_handler =
  | P_println_int
  | P_println_string
  | P_println_float
  | P_array_get
  | P_array_set
  | P_obj_dup
  | P_obj_tag
  | P_obj_block
  | P_obj_with_tag
  | P_fresh_oo_id
  | P_alloc_dummy
  | P_update_dummy
  | P_float_add
  | P_float_sub
  | P_float_mul
  | P_float_div
  | P_float_neg
  | P_float_abs
  | P_float_eq
  | P_float_neq
  | P_float_lt
  | P_float_le
  | P_float_gt
  | P_float_ge
  | P_int_of_float
  | P_float_of_int
  | P_array_make
  | P_array_sub
  | P_array_blit
  | P_array_fill
  | P_array_append
  | P_int_of_string
  | P_format_int

type prim_entry =
  { name : string
  ; handler : prim_handler
  ; seed : bool
  }

let primitives : prim_entry list =
  [ { name = "caml_java_print_endline"; handler = P_println_string; seed = true }
  ; { name = "caml_java_print_int"; handler = P_println_int; seed = true }
  ; { name = "caml_java_print_float"; handler = P_println_float; seed = true }
  ; { name = "caml_array_get_addr"; handler = P_array_get; seed = true }
  ; { name = "caml_array_set_addr"; handler = P_array_set; seed = true }
  ; { name = "caml_array_unsafe_get"; handler = P_array_get; seed = false }
  ; { name = "caml_array_unsafe_set"; handler = P_array_set; seed = false }
  ; { name = "caml_array_get"; handler = P_array_get; seed = false }
  ; { name = "caml_array_set"; handler = P_array_set; seed = false }
  ; { name = "caml_array_make"; handler = P_array_make; seed = false }
  ; { name = "caml_make_vect"; handler = P_array_make; seed = false }
  ; { name = "caml_array_sub"; handler = P_array_sub; seed = false }
  ; { name = "caml_array_blit"; handler = P_array_blit; seed = false }
  ; { name = "caml_array_fill"; handler = P_array_fill; seed = false }
  ; { name = "caml_array_append"; handler = P_array_append; seed = false }
  ; { name = "caml_obj_dup"; handler = P_obj_dup; seed = true }
  ; { name = "caml_obj_tag"; handler = P_obj_tag; seed = false }
  ; { name = "caml_obj_block"; handler = P_obj_block; seed = false }
  ; { name = "caml_obj_with_tag"; handler = P_obj_with_tag; seed = false }
  ; { name = "caml_fresh_oo_id"; handler = P_fresh_oo_id; seed = false }
  ; { name = "caml_alloc_dummy"; handler = P_alloc_dummy; seed = true }
  ; { name = "caml_update_dummy"; handler = P_update_dummy; seed = true }
  ; { name = "caml_add_float"; handler = P_float_add; seed = false }
  ; { name = "caml_sub_float"; handler = P_float_sub; seed = false }
  ; { name = "caml_mul_float"; handler = P_float_mul; seed = false }
  ; { name = "caml_div_float"; handler = P_float_div; seed = false }
  ; { name = "caml_neg_float"; handler = P_float_neg; seed = false }
  ; { name = "caml_abs_float"; handler = P_float_abs; seed = false }
  ; { name = "caml_eq_float"; handler = P_float_eq; seed = false }
  ; { name = "caml_neq_float"; handler = P_float_neq; seed = false }
  ; { name = "caml_lt_float"; handler = P_float_lt; seed = false }
  ; { name = "caml_le_float"; handler = P_float_le; seed = false }
  ; { name = "caml_gt_float"; handler = P_float_gt; seed = false }
  ; { name = "caml_ge_float"; handler = P_float_ge; seed = false }
  ; { name = "caml_int_of_float"; handler = P_int_of_float; seed = false }
  ; { name = "caml_float_of_int"; handler = P_float_of_int; seed = false }
  ; { name = "caml_int_of_string"; handler = P_int_of_string; seed = false }
  ; { name = "caml_format_int"; handler = P_format_int; seed = false }
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
