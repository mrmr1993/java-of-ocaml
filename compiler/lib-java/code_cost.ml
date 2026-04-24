open Code

(* All costs are upper bounds on the emitted bytes. The emitter's
   per-op costs come from [Jvm_code] (each push/store/op takes 1–3
   bytes), plus a few bytes for kind-coercion checkcasts and
   box/unbox calls. We add modest slack (1–2 bytes per op) so the
   estimate stays conservative in the face of unusual kinds. *)

let rec constant = function
  | Int _ -> 5          (* iconst / bipush / sipush / ldc *)
  | Float _ -> 5        (* ldc2_w (3) + box/boxless *)
  | String _ -> 5       (* ldc / ldc_w *)
  | Null -> 1
  | Block (_, fields) ->
    (* new + dup + ctor + field stores. Each field is its own
       constant recursion, dup + ldc + aastore ≈ 8 extra bytes. *)
    20 + Array.fold_left (fun acc c -> acc + 8 + constant c) 0 fields

(* Per-extern body-byte cost. Measured empirically by walking each
   handler in [Jvm_generate.emit_ccall_named] (and the nearby
   dispatchers) and counting [Jvm.Code.*] calls; the accompanying
   [tests-compiler/prim_cost.ml] test emits a minimal program per
   primitive and cross-checks the table against real emission size.
   Numbers account for the primitive's body ONLY — per-arg [aload]
   and any [checkcast] around the arg load are paid via
   [prim_arg_cost]; the return-path box/store is charged by the
   enclosing [Let] / [Return]. *)
let extern_cost = function
  (* String / bytes length — single [invokevirtual String.length()I]
     plus an Integer.valueOf box (see wrapping caller). *)
  | "caml_ml_string_length" | "caml_string_length"
  | "caml_ml_bytes_length" | "caml_bytes_length" -> 6
  (* Bytes get/set — getfield Bytes.buf + invokevirtual + box/unbox. *)
  | "caml_string_get" | "caml_bytes_get"
  | "caml_bytes_unsafe_get" | "caml_string_unsafe_get" -> 16
  | "caml_bytes_set" | "caml_bytes_unsafe_set" -> 18
  (* String <-> Bytes conversions go through static runtime helpers. *)
  | "caml_string_of_bytes" | "caml_bytes_of_string" -> 6
  | "caml_create_bytes" | "caml_create_string" -> 12
  (* Blit + fill dispatch to Bytes class static methods. *)
  | "caml_blit_string" | "caml_blit_bytes"
  | "caml_fill_bytes" | "caml_fill_string" -> 24
  | "caml_string_equal" | "caml_bytes_equal" -> 12
  | "caml_string_notequal" | "caml_bytes_notequal" -> 14
  | "caml_string_compare" | "caml_bytes_compare" -> 12
  (* IO: channel ops — all go through Channel class statics. *)
  | "caml_ml_flush" | "caml_ml_output_char" -> 10
  | "caml_ml_output" | "caml_ml_output_string" | "caml_ml_output_bytes" -> 14
  | "caml_ml_input" | "caml_ml_input_char" | "caml_ml_input_scan_line" -> 10
  | "caml_ml_close_channel" | "caml_ml_input_int" -> 8
  | "caml_ml_open_descriptor_in" | "caml_ml_open_descriptor_out" -> 8
  (* Array ops. *)
  | "caml_array_unsafe_get" | "caml_array_get"
  | "caml_array_get_addr" | "caml_array_unsafe_get_addr" -> 14
  | "caml_array_unsafe_set" | "caml_array_set"
  | "caml_array_set_addr" | "caml_array_unsafe_set_addr" -> 18
  | "caml_array_make" | "caml_make_vect" -> 16
  | "caml_array_sub" | "caml_array_blit" | "caml_array_fill" -> 20
  (* Array concat / append emit inline new-Block + fill loops. *)
  | "caml_array_append" | "caml_array_concat" -> 70
  (* Bigarray + related. *)
  | "caml_ba_create" -> 14
  | "caml_ba_dim" | "caml_ba_dim_1" | "caml_ba_dim_2" | "caml_ba_dim_3"
  | "caml_ba_num_dims" | "caml_ba_kind" | "caml_ba_layout" -> 10
  | "caml_ba_get_1" | "caml_ba_get_2" -> 16
  | "caml_ba_set_1" | "caml_ba_set_2" | "caml_ba_fill" -> 18
  | "caml_ba_blit" -> 14
  | "caml_ba_uint8_get16" | "caml_ba_uint8_get32"
  | "caml_bigstring_get16" | "caml_bigstring_get32" -> 14
  | "caml_ba_uint8_get64" | "caml_bigstring_get64" -> 18
  | "caml_ba_uint8_set16" | "caml_ba_uint8_set32"
  | "caml_bigstring_set16" | "caml_bigstring_set32" -> 14
  | "caml_ba_uint8_set64" | "caml_bigstring_set64" -> 18
  (* Object / Block helpers. *)
  | "caml_obj_dup" | "caml_obj_block" | "caml_obj_with_tag" -> 12
  (* caml_obj_tag dispatches on instanceof with 3 paths; bigger. *)
  | "caml_obj_tag" -> 55
  | "caml_fresh_oo_id" -> 10
  | "caml_alloc_dummy" | "caml_alloc_dummy_function"
  | "caml_alloc_dummy_float" -> 16
  | "caml_update_dummy" -> 54  (* instanceof dispatch w/ two paths,
                                  Block branch copies tag + fields *)
  (* Float primitives — most dispatch to one JVM op + box. *)
  | "caml_add_float" | "caml_sub_float" | "caml_mul_float"
  | "caml_div_float" | "caml_neg_float" | "caml_abs_float" -> 10
  | "caml_sqrt_float" | "caml_sin_float" | "caml_cos_float"
  | "caml_tan_float" | "caml_asin_float" | "caml_acos_float"
  | "caml_atan_float" | "caml_log_float" | "caml_log10_float"
  | "caml_exp_float" | "caml_ceil_float" | "caml_floor_float"
  | "caml_sinh_float" | "caml_cosh_float" | "caml_tanh_float"
  | "caml_cbrt_float" | "caml_expm1_float" | "caml_log1p_float"
  | "caml_round_float" | "caml_trunc_float" | "caml_signbit_float"
  | "caml_log2_float" -> 12
  | "caml_asinh_float" | "caml_acosh_float" | "caml_atanh_float"
  | "caml_erf_float" | "caml_erfc_float" | "caml_exp2_float"
  | "caml_atan2_float" | "caml_hypot_float" | "caml_copysign_float"
  | "caml_fmod_float" | "caml_power_float" | "caml_nextafter_float"
  | "caml_ldexp_float" | "caml_frexp_float" | "caml_modf_float"
  | "caml_fma_float" -> 14
  | "caml_eq_float" | "caml_neq_float" | "caml_lt_float"
  | "caml_le_float" | "caml_gt_float" | "caml_ge_float" -> 20
  | "caml_int_of_float" | "caml_float_of_int" -> 10
  (* Int64 / Nativeint. *)
  | "caml_int64_add" | "caml_int64_sub" | "caml_int64_mul"
  | "caml_int64_div" | "caml_int64_mod" | "caml_int64_neg"
  | "caml_int64_and" | "caml_int64_or" | "caml_int64_xor"
  | "caml_int64_shift_left" | "caml_int64_shift_right"
  | "caml_int64_shift_right_unsigned" -> 14
  | "caml_int64_compare" | "caml_int64_to_int" | "caml_int64_of_int"
  | "caml_int64_float_of_bits" | "caml_int64_bits_of_float" -> 12
  | "caml_int64_to_string" | "caml_int64_of_string" -> 10
  | "caml_nativeint_add" | "caml_nativeint_sub" | "caml_nativeint_mul"
  | "caml_nativeint_div" | "caml_nativeint_mod" | "caml_nativeint_neg"
  | "caml_nativeint_and" | "caml_nativeint_or" | "caml_nativeint_xor"
  | "caml_nativeint_shift_left" | "caml_nativeint_shift_right"
  | "caml_nativeint_shift_right_unsigned" -> 14
  | "caml_int32_add" | "caml_int32_sub" | "caml_int32_mul"
  | "caml_int32_div" | "caml_int32_mod" | "caml_int32_neg"
  | "caml_int32_and" | "caml_int32_or" | "caml_int32_xor"
  | "caml_int32_shift_left" | "caml_int32_shift_right"
  | "caml_int32_shift_right_unsigned" -> 14
  (* Structural comparison — dispatches to Compare class statics. *)
  | "caml_equal" | "caml_notequal" | "caml_compare"
  | "caml_lessthan" | "caml_lessequal" | "caml_greaterthan"
  | "caml_greaterequal" | "caml_int_compare" -> 8
  (* Stubs / no-ops. *)
  | "caml_record_backtrace" | "caml_backtrace_status" -> 13
  | "caml_ensure_stack_capacity" | "caml_ml_set_binary_mode"
  | "caml_ml_set_channel_name" | "caml_register_named_value"
  | "caml_init_signals"
  | "caml_ml_debug_info_status" | "caml_ml_enable_runtime_warnings"
  | "caml_ml_runtime_warnings_enabled" | "caml_runtime_parameters"
  | "caml_runtime_variant" | "caml_ml_out_channels_list"
  | "caml_ml_seek_out" | "caml_ml_seek_out_64" | "caml_ml_seek_in"
  | "caml_ml_seek_in_64" | "caml_ml_pos_out" | "caml_ml_pos_out_64"
  | "caml_ml_pos_in" | "caml_ml_pos_in_64" -> 4
  | "caml_channel_descriptor" | "caml_sys_executable_name"
  | "caml_sys_system_command" | "caml_sys_file_exists"
  | "caml_unix_inet_addr_of_string" | "caml_unix_string_of_inet_addr"
  | "unix_inet_addr_of_string" | "unix_string_of_inet_addr" -> 2
  (* Sys constants. *)
  | "caml_sys_const_big_endian" | "caml_sys_const_word_size"
  | "caml_sys_const_int_size" | "caml_sys_const_max_wosize"
  | "caml_sys_const_ostype_unix" | "caml_sys_const_ostype_win32"
  | "caml_sys_const_ostype_cygwin" | "caml_sys_const_backend_type"
  | "caml_sys_const_naked_pointers_checked" | "caml_sys_const_max_int" -> 4
  | "caml_sys_get_config" -> 30
  | "caml_sys_get_argv" -> 35
  | "caml_sys_getenv"
  | "caml_sys_unsafe_getenv" -> 50  (* null-check + raise path *)
  | "caml_sys_argv" | "caml_sys_time" | "caml_sys_time_include_children"
  | "caml_sys_random_seed" -> 20
  | "caml_sys_open" | "caml_sys_close" | "caml_sys_remove" -> 10
  (* Atomics lower to straight array ops. *)
  | "caml_atomic_load" | "caml_atomic_cas" | "caml_atomic_exchange"
  | "caml_atomic_make_contended" -> 16
  | "caml_atomic_fetch_add" -> 30
  (* Formatting + parsing. *)
  | "caml_format_int" | "caml_format_float" -> 20
  | "caml_int_of_string" | "caml_float_of_string" -> 12
  (* Mutex / CondVar / Thread. *)
  | "caml_ml_mutex_new" | "caml_ml_mutex_lock"
  | "caml_ml_mutex_unlock" | "caml_ml_mutex_try_lock"
  | "caml_mutex_new" | "caml_mutex_lock"
  | "caml_mutex_unlock" | "caml_mutex_try_lock" -> 8
  | "caml_ml_condition_new" | "caml_ml_condition_wait"
  | "caml_ml_condition_signal" | "caml_ml_condition_broadcast"
  | "caml_condition_new" | "caml_condition_wait"
  | "caml_condition_signal" | "caml_condition_broadcast" -> 8
  | "caml_thread_new" | "caml_thread_self" | "caml_thread_id"
  | "caml_thread_join" | "caml_thread_yield"
  | "caml_thread_initialize" | "caml_thread_cleanup"
  | "caml_thread_uncaught_exception" -> 8
  (* Build-info stub. *)
  | "generated_hg_version" | "generated_build_info" -> 4
  | "Base_internalhash_fold_int"
  | "Base_internalhash_fold_int64"
  | "Base_internalhash_fold_nativeint"
  | "Base_internalhash_fold_float"
  | "Base_internalhash_fold_string"
  | "internalhash_fold_bigstring"
  | "Base_internalhash_get_hash_value"
  | "Core_kernel_heap_block_is_heap_block"
  | "core_heap_block_is_heap_block" -> 10
  (* MD5. *)
  | "caml_md5_string" | "caml_md5_bytes" -> 10
  (* Lazy. *)
  | "caml_lazy_reset_to_lazy" | "caml_lazy_update_to_forward"
  | "caml_lazy_make_forward" -> 20
  | "caml_lazy_update_to_forcing" -> 30
  (* Ephemeron. *)
  | "caml_ephe_create" | "caml_ephe_get_key" | "caml_ephe_set_key"
  | "caml_ephe_unset_key" | "caml_ephe_get_data" | "caml_ephe_set_data"
  | "caml_ephe_unset_data" | "caml_ephe_check_key" | "caml_ephe_check_data"
  | "caml_ephe_blit_key" | "caml_ephe_blit_data" -> 10
  (* Globals helpers injected by our own passes / parse_bytecode. *)
  | "get_global" | "get_global_field" -> 12
  | "set_global" -> 14
  | "alloc_block" -> 22
  (* GC / signal / memprof no-ops. *)
  | "caml_gc_minor" | "caml_gc_major" | "caml_gc_full_major"
  | "caml_gc_compaction" | "caml_gc_major_slice" | "caml_gc_set"
  | "caml_gc_quick_stat" | "caml_gc_stat" | "caml_gc_counters"
  | "caml_gc_get" | "caml_gc_huge_fallback_count" | "caml_gc_minor_words"
  | "caml_final_register" | "caml_final_register_called_without_value"
  | "caml_final_release" | "caml_install_signal_handler"
  | "caml_register_channel_for_spacetime"
  | "caml_memprof_start" | "caml_memprof_stop" | "caml_memprof_discard"
  | "caml_set_parser_trace" | "caml_restore_raw_backtrace"
  | "caml_get_current_callstack" | "caml_get_callstack" | "caml_get_exception_raw_backtrace"
  | "caml_get_exception_backtrace" -> 4
  | "caml_int32_float_of_bits" | "caml_int32_bits_of_float" -> 12
  (* Bigstring <-> bytes blits. *)
  | "caml_bigstring_blit_string_to_bytes"
  | "caml_bigstring_blit_bytes_to_bigstring"
  | "caml_bigstring_blit_bigstring_to_bytes" -> 20
  (* Print/debug helpers. *)
  | "caml_java_print_endline" | "caml_java_print_int"
  | "caml_java_print_float" -> 10
  | _ ->
    (* Unknown extern — emitted as the runtime-throwing stub:
       [new UnsupportedOperationException + dup + ldc "..." +
        invokespecial + athrow + aconst_null]. Around 40 bytes
       exactly; the big [200] baseline we previously used was
       a defensive over-estimate that caused [Method_split] to
       over-cut by 5-10x. *)
    40

let prim_cost = function
  | Vectlength | Array_get -> 12
  | Not | IsInt -> 10
  | Eq | Neq | Lt | Le | Gt | Ge | Ult | Uge -> 16
  | Extern name -> extern_cost name

let prim_arg_cost = function
  | Pv _ -> 2        (* aload — checkcast, when needed, is part of
                        the primitive's body and already folded into
                        the matching [extern_cost] entry. *)
  | Pc c -> constant c

let expr = function
  | Apply { args; _ } ->
    (* checkcast Closure, load each arg boxed, invokevirtual
       applyN(Object...)Object. *)
    20 + (6 * List.length args)
  | Block (_, fields) -> 15 + (6 * Array.length fields)
  | Field _ -> 10
  | Closure { captures; _ } -> 18 + (5 * List.length captures)
  | Constant c -> constant c
  | Prim (p, args) ->
    prim_cost p + List.fold_left (fun acc a -> acc + prim_arg_cost a) 0 args

let instr = function
  | Let (_, e) -> 5 + expr e
      (* astore (2 bytes) + ~3 bytes typical kind coercion at the
         store boundary (Integer.valueOf for K_int → K_obj is the
         common case in OCaml-on-JVM since most Lets bind a
         primitive that gets passed onward as Object). *)
  | Set_field _ -> 14
  | Offset_ref _ -> 14
  | Array_set _ -> 18
  | Source_pc _ -> 0                    (* no emitted bytes *)

let last = function
  | Return _ -> 3                        (* aload + areturn *)
  | Raise _ -> 14                        (* new + dup + load + ctor + athrow *)
  | Stop -> 2
  | Branch (_, args) -> 8 + (6 * List.length args)
      (* Per-arg coefficient bumped 4 → 6 to match the parallel-
         rename + box/unbox coercion cost as for [Cond]. *)
  | Cond (_, (_, a1), (_, a2)) ->
    (* Test + conditional branch + two edge sequences + goto. The
       per-arg coefficient is 6 (was 4): each parallel-rename arg
       averages aload + box/unbox + astore = ~6 bytes once kind
       coercions are included. The 30 base captures the common
       K_int test (load + ifeq + goto); K_obj scrutinees emit
       another ~15 bytes (instanceof + checkcast + intValue) but
       are rarer so we don't differentiate. *)
    30 + (6 * (List.length a1 + List.length a2))
  | Switch (_, ints, tags) ->
    let n = Array.length ints + Array.length tags in
    let sum_args =
      let cont_args (_, args) = List.length args in
      Array.fold_left (fun acc c -> acc + cont_args c) 0 ints
      + Array.fold_left (fun acc c -> acc + cont_args c) 0 tags
    in
    (* tableswitch header (~16) + padding + 4 bytes per case target,
       plus per-case edge moves (parallel-rename: ~4 bytes per arg
       across all case continuations). Previously this only counted
       cases (24 + 10*N), missing the args entirely — caused a large test binary
       stub [ocaml_fn_33445] to be under-estimated by ~3x because
       its 134 switches average 7 args/case and 11 cases each. *)
    24 + (8 * n) + (6 * sum_args)
  | Pushtrap (_, _, _) -> 10        (* entry bookkeeping — exception
                                       entries are installed post-emit *)
  | Poptrap (_, args) -> 6 + (4 * List.length args)
  | Invoke_tail { args; _ } ->
    (* aload 0 (or nothing for static), load each arg as Object,
       invokevirtual/static, areturn. *)
    12 + (4 * List.length args)

let block (b : block) =
  Array.fold_left (fun acc i -> acc + instr i) 0 b.body + last b.branch

(* Conservative upper bound on per-instruction bytes. Callers use
   this with [Array.length body] for an O(1) "could this block need
   splitting?" filter that dodges the full walk on the overwhelming
   majority of blocks. Keep strictly >= every return value of
   [instr]: an [Apply] with many args or a [Closure] with many
   captures can run large; 256 bytes is enough slack that we'd need
   a single instruction with ~40 extern-call args to breach it. *)
let max_instr_cost = 256

(* Entry prologue overhead: the emitter pre-binds arg_vars to locals
   and null-initialises remaining start-block params. Tiny compared
   to the body but accounted for so [program] and [subset] align. *)
let entry_overhead (prog : program) =
  match Addr.Map.find_opt prog.start prog.blocks with
  | None -> 0
  | Some b ->
    (* For method-entry blocks [arg_vars] are already in locals,
       so there's no per-param emission; the emitter only pays for
       a handful of null-init [aconst_null/astore] pairs for
       [Dummy] stack slots that reach the start. Flat constant. *)
    2 * List.length b.params

let program (prog : program) =
  let body =
    Addr.Map.fold (fun _ b acc -> acc + block b) prog.blocks 0
  in
  entry_overhead prog + body

(* [Array.length]-based upper bound on [program]. Cheap (no per-instr
   walk); [max_instr_cost * total_instrs + per_block_slack]. When
   this sits comfortably under the method-size limit we can skip the
   exact [program] walk entirely — the common case for the tens of
   thousands of tiny closures in a real link. *)
let program_upper_bound (prog : program) =
  let body_slack = 64 in
  Addr.Map.fold
    (fun _ b acc ->
      acc + (Array.length b.body * max_instr_cost) + body_slack)
    prog.blocks
    (entry_overhead prog)

let subset (prog : program) keep =
  let body =
    Addr.Set.fold
      (fun a acc ->
        match Addr.Map.find_opt a prog.blocks with
        | None -> acc
        | Some b -> acc + block b)
      keep
      0
  in
  entry_overhead prog + body

