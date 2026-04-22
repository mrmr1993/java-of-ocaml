(* Measurement / regression test for [Code_cost.extern_cost].

   For each curated extern primitive, construct a minimal
   [Code.program] that invokes it, run [Jvm_generate.emit_program]
   on the result, and compare [Code_cost.program]'s estimate
   against the emitted byte count. The test snapshot pins the
   (estimate, actual, delta) triple per name — drift in either
   direction shows up as a diff, so a cost-table entry that no
   longer matches what [Jvm_generate] emits fails loudly. *)

open Java_of_ocaml_compiler.Code

let pc_int n = Pc (Int n)

(* Curated set — names, arity, [Pc] extras. Covers what
   [Code_cost.extern_cost] explicitly tables plus the unlisted
   stub path. *)
let tests : (string * int * prim_arg list) list =
  [ "caml_ml_string_length", 1, []
  ; "caml_string_length", 1, []
  ; "caml_ml_bytes_length", 1, []
  ; "caml_bytes_length", 1, []
  ; "caml_string_get", 2, []
  ; "caml_bytes_get", 2, []
  ; "caml_bytes_set", 3, []
  ; "caml_string_of_bytes", 1, []
  ; "caml_bytes_of_string", 1, []
  ; "caml_create_bytes", 1, []
  ; "caml_blit_string", 5, []
  ; "caml_blit_bytes", 5, []
  ; "caml_fill_bytes", 4, []
  ; "caml_string_equal", 2, []
  ; "caml_string_notequal", 2, []
  ; "caml_bytes_equal", 2, []
  ; "caml_string_compare", 2, []
  ; "caml_ml_flush", 1, []
  ; "caml_ml_output_char", 2, []
  ; "caml_ml_output", 4, []
  ; "caml_ml_output_string", 2, []
  ; "caml_array_unsafe_get", 2, []
  ; "caml_array_get", 2, []
  ; "caml_array_unsafe_set", 3, []
  ; "caml_array_set", 3, []
  ; "caml_array_make", 2, []
  ; "caml_array_sub", 3, []
  ; "caml_array_blit", 5, []
  ; "caml_array_fill", 4, []
  ; "caml_array_append", 2, []
  ; "caml_ba_create", 3, []
  ; "caml_ba_dim_1", 1, []
  ; "caml_ba_dim_2", 1, []
  ; "caml_ba_dim_3", 1, []
  ; "caml_ba_num_dims", 1, []
  ; "caml_ba_kind", 1, []
  ; "caml_ba_layout", 1, []
  ; "caml_ba_get_1", 2, []
  ; "caml_ba_get_2", 3, []
  ; "caml_ba_set_1", 3, []
  ; "caml_ba_set_2", 4, []
  ; "caml_ba_fill", 2, []
  ; "caml_ba_blit", 2, []
  ; "caml_ba_uint8_get16", 2, []
  ; "caml_ba_uint8_get32", 2, []
  ; "caml_ba_uint8_get64", 2, []
  ; "caml_ba_uint8_set16", 3, []
  ; "caml_ba_uint8_set32", 3, []
  ; "caml_ba_uint8_set64", 3, []
  ; "caml_obj_dup", 1, []
  ; "caml_obj_tag", 1, []
  ; "caml_obj_block", 2, []
  ; "caml_obj_with_tag", 2, []
  ; "caml_fresh_oo_id", 1, []
  ; "caml_alloc_dummy", 1, []
  ; "caml_alloc_dummy_function", 2, []
  ; "caml_alloc_dummy_float", 1, []
  ; "caml_update_dummy", 2, []
  ; "caml_add_float", 2, []
  ; "caml_sub_float", 2, []
  ; "caml_mul_float", 2, []
  ; "caml_div_float", 2, []
  ; "caml_neg_float", 1, []
  ; "caml_abs_float", 1, []
  ; "caml_sqrt_float", 1, []
  ; "caml_sin_float", 1, []
  ; "caml_cos_float", 1, []
  ; "caml_eq_float", 2, []
  ; "caml_neq_float", 2, []
  ; "caml_lt_float", 2, []
  ; "caml_le_float", 2, []
  ; "caml_gt_float", 2, []
  ; "caml_ge_float", 2, []
  ; "caml_int_of_float", 1, []
  ; "caml_float_of_int", 1, []
  ; "caml_int64_add", 2, []
  ; "caml_int64_sub", 2, []
  ; "caml_int64_mul", 2, []
  ; "caml_int64_neg", 1, []
  ; "caml_int64_and", 2, []
  ; "caml_int64_or", 2, []
  ; "caml_int64_xor", 2, []
  ; "caml_int64_to_int", 1, []
  ; "caml_int64_of_int", 1, []
  ; "caml_int64_compare", 2, []
  ; "caml_equal", 2, []
  ; "caml_notequal", 2, []
  ; "caml_compare", 2, []
  ; "caml_lessthan", 2, []
  ; "caml_lessequal", 2, []
  ; "caml_greaterthan", 2, []
  ; "caml_greaterequal", 2, []
  ; "caml_int_compare", 2, []
  ; "caml_atomic_load", 1, []
  ; "caml_atomic_cas", 3, []
  ; "caml_atomic_exchange", 2, []
  ; "caml_atomic_fetch_add", 2, []
  ; "caml_format_int", 2, []
  ; "caml_int_of_string", 1, []
  ; "caml_float_of_string", 1, []
  ; "caml_md5_string", 3, []
  ; "caml_md5_bytes", 3, []
  ; "caml_ml_mutex_new", 1, []
  ; "caml_ml_mutex_lock", 1, []
  ; "caml_ml_mutex_unlock", 1, []
  ; "caml_ml_condition_new", 1, []
  ; "caml_ml_condition_signal", 1, []
  ; "caml_ml_condition_broadcast", 1, []
  ; "caml_thread_self", 1, []
  ; "caml_thread_yield", 1, []
  ; "caml_thread_id", 1, []
  ; "caml_sys_const_big_endian", 1, []
  ; "caml_sys_const_word_size", 1, []
  ; "caml_sys_const_int_size", 1, []
  ; "caml_sys_const_max_wosize", 1, []
  ; "caml_sys_get_config", 1, []
  ; "caml_sys_get_argv", 1, []
  ; "caml_sys_time", 1, []
  ; "caml_sys_random_seed", 1, []
  ; "caml_ensure_stack_capacity", 1, []
  ; "caml_register_named_value", 2, []
  ; "caml_init_signals", 1, []
  ; "caml_record_backtrace", 1, []
  ; "caml_channel_descriptor", 1, []
  ; "caml_sys_executable_name", 1, []
  ; "caml_gc_minor", 1, []
  ; "caml_gc_major", 1, []
  ; "caml_final_register", 2, []
  ; "caml_java_print_int", 1, []
  ; "caml_java_print_endline", 1, []
  ; "caml_java_print_float", 1, []
  ; "caml_lazy_update_to_forcing", 1, []
  ; "caml_lazy_reset_to_lazy", 1, []
  ; "caml_lazy_update_to_forward", 1, []
  ; "caml_lazy_make_forward", 1, []
    (* Primitives with compile-time [Pc Int] args — must be
       supplied so [emit_ccall_named]'s pattern matches. *)
  ; "alloc_block", 0, [ pc_int 0; pc_int 4 ]
  ; "get_global", 0, [ pc_int 0 ]
  ; "get_global_field", 0, [ pc_int 0; pc_int 0 ]
    (* set_global takes [Pc; Pv] — tested below via [prefix_tests]. *)
    (* Unix init stubs — always null. *)
  ; "caml_unix_inet_addr_of_string", 1, []
  ; "unix_inet_addr_of_string", 1, []
    (* Unlisted name — exercises the default stub path. *)
  ; "nonexistent_primitive_stub_path", 1, []
  ]

(* Primitives whose [Pc] args go BEFORE the [Pv] args. *)
let prefix_tests : (string * int * prim_arg list) list =
  [ "set_global", 1, [ pc_int 0 ]
  ]

let%expect_test "primitive cost table vs real emission" =
  List.iter
    (fun (name, nargs, extras) ->
      match Util.measure_extern_cost ~extras ~nargs name with
      | Ok (est, act) ->
        let delta = act - est in
        Printf.printf "%-40s est=%3d act=%3d delta=%+3d\n" name est act delta
      | Error msg -> Printf.printf "%-40s ERROR: %s\n" name msg)
    tests;
  List.iter
    (fun (name, nargs, prefix_extras) ->
      match
        Util.measure_extern_cost ~prefix_extras ~nargs name
      with
      | Ok (est, act) ->
        let delta = act - est in
        Printf.printf "%-40s est=%3d act=%3d delta=%+3d\n" name est act delta
      | Error msg -> Printf.printf "%-40s ERROR: %s\n" name msg)
    prefix_tests;
  [%expect {|
    caml_ml_string_length                    est= 16 act= 14 delta= -2
    caml_string_length                       est= 16 act= 14 delta= -2
    caml_ml_bytes_length                     est= 16 act= 11 delta= -5
    caml_bytes_length                        est= 16 act= 11 delta= -5
    caml_string_get                          est= 30 act= 19 delta=-11
    caml_bytes_get                           est= 30 act= 16 delta=-14
    caml_bytes_set                           est= 36 act= 25 delta=-11
    caml_string_of_bytes                     est= 16 act=  7 delta= -9
    caml_bytes_of_string                     est= 16 act= 10 delta= -6
    caml_create_bytes                        est= 22 act= 15 delta= -7
    caml_blit_string                         est= 50 act= 37 delta=-13
    caml_blit_bytes                          est= 50 act= 37 delta=-13
    caml_fill_bytes                          est= 46 act= 32 delta=-14
    caml_string_equal                        est= 26 act= 18 delta= -8
    caml_string_notequal                     est= 28 act= 20 delta= -8
    caml_bytes_equal                         est= 26 act= 18 delta= -8
    caml_string_compare                      est= 26 act= 18 delta= -8
    caml_ml_flush                            est= 20 act= 15 delta= -5
    caml_ml_output_char                      est= 24 act= 20 delta= -4
    caml_ml_output                           est= 36 act= 31 delta= -5
    caml_ml_output_string                    est= 28 act= 14 delta=-14
    caml_array_unsafe_get                    est= 28 act= 16 delta=-12
    caml_array_get                           est= 28 act= 16 delta=-12
    caml_array_unsafe_set                    est= 36 act= 22 delta=-14
    caml_array_set                           est= 36 act= 22 delta=-14
    caml_array_make                          est= 30 act= 26 delta= -4
    caml_array_sub                           est= 38 act= 37 delta= -1
    caml_array_blit                          est= 46 act= 43 delta= -3
    caml_array_fill                          est= 42 act= 37 delta= -5
    caml_array_append                        est= 84 act= 82 delta= -2
    caml_ba_create                           est= 32 act= 20 delta=-12
    caml_ba_dim_1                            est= 20 act= 14 delta= -6
    caml_ba_dim_2                            est= 20 act= 14 delta= -6
    caml_ba_dim_3                            est= 20 act= 14 delta= -6
    caml_ba_num_dims                         est= 20 act= 14 delta= -6
    caml_ba_kind                             est= 20 act= 14 delta= -6
    caml_ba_layout                           est= 20 act= 14 delta= -6
    caml_ba_get_1                            est= 30 act= 15 delta=-15
    caml_ba_get_2                            est= 34 act= 20 delta=-14
    caml_ba_set_1                            est= 36 act= 20 delta=-16
    caml_ba_set_2                            est= 40 act= 27 delta=-13
    caml_ba_fill                             est= 32 act= 15 delta=-17
    caml_ba_blit                             est= 28 act= 18 delta=-10
    caml_ba_uint8_get16                      est= 28 act= 19 delta= -9
    caml_ba_uint8_get32                      est= 28 act= 19 delta= -9
    caml_ba_uint8_get64                      est= 32 act= 18 delta=-14
    caml_ba_uint8_set16                      est= 32 act= 24 delta= -8
    caml_ba_uint8_set32                      est= 32 act= 24 delta= -8
    caml_ba_uint8_set64                      est= 36 act= 23 delta=-13
    caml_obj_dup                             est= 22 act= 10 delta=-12
    caml_obj_tag                             est= 65 act= 65 delta= +0
    caml_obj_block                           est= 26 act= 23 delta= -3
    caml_obj_with_tag                        est= 26 act= 27 delta= +1
    caml_fresh_oo_id                         est= 20 act=  8 delta=-12
    caml_alloc_dummy                         est= 26 act= 19 delta= -7
    caml_alloc_dummy_function                est= 30 act= 10 delta=-20
    caml_alloc_dummy_float                   est= 26 act= 19 delta= -7
    caml_update_dummy                        est= 54 act= 52 delta= -2
    caml_add_float                           est= 24 act= 21 delta= -3
    caml_sub_float                           est= 24 act= 21 delta= -3
    caml_mul_float                           est= 24 act= 21 delta= -3
    caml_div_float                           est= 24 act= 21 delta= -3
    caml_neg_float                           est= 20 act= 14 delta= -6
    caml_abs_float                           est= 20 act= 16 delta= -4
    caml_sqrt_float                          est= 22 act= 16 delta= -6
    caml_sin_float                           est= 22 act= 16 delta= -6
    caml_cos_float                           est= 22 act= 16 delta= -6
    caml_eq_float                            est= 34 act= 33 delta= -1
    caml_neq_float                           est= 34 act= 33 delta= -1
    caml_lt_float                            est= 34 act= 33 delta= -1
    caml_le_float                            est= 34 act= 33 delta= -1
    caml_gt_float                            est= 34 act= 33 delta= -1
    caml_ge_float                            est= 34 act= 33 delta= -1
    caml_int_of_float                        est= 20 act= 14 delta= -6
    caml_float_of_int                        est= 20 act= 11 delta= -9
    caml_int64_add                           est= 28 act= 15 delta=-13
    caml_int64_sub                           est= 28 act= 15 delta=-13
    caml_int64_mul                           est= 28 act= 15 delta=-13
    caml_int64_neg                           est= 24 act= 11 delta=-13
    caml_int64_and                           est= 28 act= 15 delta=-13
    caml_int64_or                            est= 28 act= 15 delta=-13
    caml_int64_xor                           est= 28 act= 15 delta=-13
    caml_int64_to_int                        est= 22 act= 10 delta=-12
    caml_int64_of_int                        est= 22 act= 12 delta=-10
    caml_int64_compare                       est= 26 act= 16 delta=-10
    caml_equal                               est= 22 act= 12 delta=-10
    caml_notequal                            est= 22 act= 12 delta=-10
    caml_compare                             est= 22 act= 12 delta=-10
    caml_lessthan                            est= 22 act= 12 delta=-10
    caml_lessequal                           est= 22 act= 12 delta=-10
    caml_greaterthan                         est= 22 act= 12 delta=-10
    caml_greaterequal                        est= 22 act= 12 delta=-10
    caml_int_compare                         est= 22 act= 18 delta= -4
    caml_atomic_load                         est= 26 act= 12 delta=-14
    caml_atomic_cas                          est= 34 act= 30 delta= -4
    caml_atomic_exchange                     est= 30 act= 22 delta= -8
    caml_atomic_fetch_add                    est= 44 act= 36 delta= -8
    caml_format_int                          est= 34 act= 14 delta=-20
    caml_int_of_string                       est= 22 act= 13 delta= -9
    caml_float_of_string                     est= 22 act= 13 delta= -9
    caml_md5_string                          est= 28 act= 17 delta=-11
    caml_md5_bytes                           est= 28 act= 17 delta=-11
    caml_ml_mutex_new                        est= 18 act=  6 delta=-12
    caml_ml_mutex_lock                       est= 18 act= 14 delta= -4
    caml_ml_mutex_unlock                     est= 18 act= 14 delta= -4
    caml_ml_condition_new                    est= 18 act=  6 delta=-12
    caml_ml_condition_signal                 est= 18 act= 14 delta= -4
    caml_ml_condition_broadcast              est= 18 act= 14 delta= -4
    caml_thread_self                         est= 18 act=  6 delta=-12
    caml_thread_yield                        est= 18 act= 10 delta= -8
    caml_thread_id                           est= 18 act= 14 delta= -4
    caml_sys_const_big_endian                est= 14 act=  8 delta= -6
    caml_sys_const_word_size                 est= 14 act=  9 delta= -5
    caml_sys_const_int_size                  est= 14 act=  9 delta= -5
    caml_sys_const_max_wosize                est= 14 act=  9 delta= -5
    caml_sys_get_config                      est= 40 act= 37 delta= -3
    caml_sys_get_argv                        est= 45 act= 32 delta=-13
    caml_sys_time                            est= 30 act= 14 delta=-16
    caml_sys_random_seed                     est= 30 act= 24 delta= -6
    caml_ensure_stack_capacity               est= 14 act=  8 delta= -6
    caml_register_named_value                est= 18 act=  8 delta=-10
    caml_init_signals                        est= 14 act=  8 delta= -6
    caml_record_backtrace                    est= 14 act=  8 delta= -6
    caml_channel_descriptor                  est= 12 act=  4 delta= -8
    caml_sys_executable_name                 est= 12 act=  4 delta= -8
    caml_gc_minor                            est= 14 act=  8 delta= -6
    caml_gc_major                            est= 14 act=  8 delta= -6
    caml_final_register                      est= 18 act=  8 delta=-10
    caml_java_print_int                      est= 20 act= 19 delta= -1
    caml_java_print_endline                  est= 20 act= 18 delta= -2
    caml_java_print_float                    est= 20 act= 21 delta= +1
    caml_lazy_update_to_forcing              est= 40 act= 33 delta= -7
    caml_lazy_reset_to_lazy                  est= 30 act= 18 delta=-12
    caml_lazy_update_to_forward              est= 30 act= 18 delta=-12
    caml_lazy_make_forward                   est= 30 act= 21 delta= -9
    alloc_block                              est= 30 act= 15 delta=-15
    get_global                               est= 19 act=  8 delta=-11
    get_global_field                         est= 20 act= 16 delta= -4
    caml_unix_inet_addr_of_string            est= 12 act=  4 delta= -8
    unix_inet_addr_of_string                 est= 12 act=  4 delta= -8
    nonexistent_primitive_stub_path          est= 50 act= 14 delta=-36
    set_global                               est= 25 act= 14 delta=-11
    |}]
