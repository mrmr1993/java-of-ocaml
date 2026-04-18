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
  | P_float_of_string
  | P_format_float
  | P_string_length
  | P_string_equal
  | P_string_notequal
  | P_string_compare
  | P_noop1
  | P_noop2
  | P_noop_float1
  | P_noop_null1
  | P_noop_null2
  | P_atomic_load
  | P_atomic_cas
  | P_atomic_exchange
  | P_atomic_fetch_add
  | P_int_compare
  | P_poly_compare
  | P_poly_equal
  | P_poly_notequal
  | P_poly_lessthan
  | P_poly_lessequal
  | P_poly_greaterthan
  | P_poly_greaterequal
  | P_ml_open_descriptor_out
  | P_ml_output
  | P_ml_output_char
  | P_ml_flush
    (* Stub: 1 arg, returns a dummy K_float (0.0). For Int64/Int32 bit
       conversions we don't implement yet; Stdlib init calls them to
       set up infinity / nan / max_float, which would be wrong but at
       least lets init proceed. *)

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
  ; { name = "caml_float_of_string"; handler = P_float_of_string; seed = false }
  ; { name = "caml_format_float"; handler = P_format_float; seed = false }
  ; { name = "caml_ml_string_length"; handler = P_string_length; seed = false }
  ; { name = "caml_string_equal"; handler = P_string_equal; seed = false }
  ; { name = "caml_string_notequal"; handler = P_string_notequal; seed = false }
  ; { name = "caml_string_compare"; handler = P_string_compare; seed = false }
  (* Stdlib-init primitives stubbed as unit-returning no-ops. These
     manage things we don't model on the JVM (GC stack hints, signal
     handlers, backtrace state). *)
  ; { name = "caml_ensure_stack_capacity"; handler = P_noop1; seed = false }
  ; { name = "caml_register_named_value"; handler = P_noop2; seed = false }
  ; { name = "caml_init_signals"; handler = P_noop1; seed = false }
  ; { name = "caml_record_backtrace"; handler = P_noop1; seed = false }
  ; { name = "caml_backtrace_status"; handler = P_noop1; seed = false }
  ; { name = "caml_ml_debug_info_status"; handler = P_noop1; seed = false }
  ; { name = "caml_ml_enable_runtime_warnings"; handler = P_noop1; seed = false }
  ; { name = "caml_ml_runtime_warnings_enabled"; handler = P_noop1; seed = false }
  ; { name = "caml_runtime_parameters"; handler = P_noop1; seed = false }
  ; { name = "caml_runtime_variant"; handler = P_noop1; seed = false }
  (* Int64 / Int32 bit conversions stubbed until we have K_int32 /
     K_int64 kinds. Returning 0.0 breaks the exact bit-pattern
     initialisation of [infinity] / [neg_infinity] / [nan] /
     [max_float] / [min_float], but lets Stdlib init finish so user
     code can run. Address at the Int64 phase of the stdlib plan. *)
  ; { name = "caml_int64_float_of_bits"; handler = P_noop_float1; seed = false }
  ; { name = "caml_int32_float_of_bits"; handler = P_noop_float1; seed = false }
  (* IO descriptor / channel primitives stubbed as null-returning
     no-ops so Stdlib init can complete. Callers treat these as
     reference values (channels, blocks); returning null lets
     downstream [checkcast] succeed, trading a readable
     NullPointerException at first-use for a
     ClassCastException at the call site. *)
  ; { name = "caml_ml_open_descriptor_in"; handler = P_noop_null1; seed = false }
  ; { name = "caml_ml_open_descriptor_out"; handler = P_ml_open_descriptor_out; seed = false }
  ; { name = "caml_ml_output"; handler = P_ml_output; seed = false }
  ; { name = "caml_ml_output_bytes"; handler = P_ml_output; seed = false }
  ; { name = "caml_ml_output_string"; handler = P_ml_output; seed = false }
  ; { name = "caml_ml_output_char"; handler = P_ml_output_char; seed = false }
  ; { name = "caml_ml_flush"; handler = P_ml_flush; seed = false }
  (* Returns an OCaml list (nil = Val_int 0). *)
  ; { name = "caml_ml_out_channels_list"; handler = P_noop1; seed = false }
  ; { name = "caml_channel_descriptor"; handler = P_noop_null1; seed = false }
  ; { name = "caml_sys_get_config"; handler = P_noop_null1; seed = false }
  ; { name = "caml_sys_get_argv"; handler = P_noop_null1; seed = false }
  ; { name = "caml_sys_executable_name"; handler = P_noop_null1; seed = false }
  ; { name = "caml_sys_const_backend_type"; handler = P_noop_null1; seed = false }
  (* Atomic primitives: we're single-threaded, so OCaml's atomic
     refs (Block of size 1 holding the current value) lower to
     plain getfield / aaload / aastore without synchronisation. *)
  ; { name = "caml_atomic_load"; handler = P_atomic_load; seed = false }
  ; { name = "caml_atomic_cas"; handler = P_atomic_cas; seed = false }
  ; { name = "caml_atomic_exchange"; handler = P_atomic_exchange; seed = false }
  ; { name = "caml_atomic_fetch_add"; handler = P_atomic_fetch_add; seed = false }
  ; { name = "caml_int_compare"; handler = P_int_compare; seed = false }
  (* Polymorphic comparison: compare / = / <> / < / <= / > / >=.
     The implementation walks the structural form (ints as Integer,
     blocks recursively, strings lex). Covers the cases OCaml's
     Stdlib reaches at init time. *)
  ; { name = "caml_compare"; handler = P_poly_compare; seed = false }
  ; { name = "caml_equal"; handler = P_poly_equal; seed = false }
  ; { name = "caml_notequal"; handler = P_poly_notequal; seed = false }
  ; { name = "caml_lessthan"; handler = P_poly_lessthan; seed = false }
  ; { name = "caml_lessequal"; handler = P_poly_lessequal; seed = false }
  ; { name = "caml_greaterthan"; handler = P_poly_greaterthan; seed = false }
  ; { name = "caml_greaterequal"; handler = P_poly_greaterequal; seed = false }
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
