
(library
 ;; compiler/tests-compiler/arithmetic.ml
 (name arithmetic_15)
 (enabled_if true)
 (modules arithmetic)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/array_module.ml
 (name array_module_15)
 (enabled_if true)
 (modules array_module)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/bigarray_module.ml
 (name bigarray_module_15)
 (enabled_if true)
 (modules bigarray_module)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/branch_relaxation.ml
 (name branch_relaxation_15)
 (enabled_if true)
 (modules branch_relaxation)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/bytecode_smoke.ml
 (name bytecode_smoke_15)
 (enabled_if true)
 (modules bytecode_smoke)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/cmo_reader.ml
 (name cmo_reader_15)
 (enabled_if true)
 (modules cmo_reader)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/corecursion.ml
 (name corecursion_15)
 (enabled_if true)
 (modules corecursion)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/deadcode.ml
 (name deadcode_15)
 (enabled_if true)
 (modules deadcode)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/emission_snapshots.ml
 (name emission_snapshots_15)
 (enabled_if true)
 (modules emission_snapshots)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/ephemeron.ml
 (name ephemeron_15)
 (enabled_if true)
 (modules ephemeron)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/eval.ml
 (name eval_15)
 (enabled_if true)
 (modules eval)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/exceptions.ml
 (name exceptions_15)
 (enabled_if true)
 (modules exceptions)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/extensible.ml
 (name extensible_15)
 (enabled_if true)
 (modules extensible)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/file_io.ml
 (name file_io_15)
 (enabled_if true)
 (modules file_io)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/float_module.ml
 (name float_module_15)
 (enabled_if true)
 (modules float_module)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/functions.ml
 (name functions_15)
 (enabled_if true)
 (modules functions)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/gadts.ml
 (name gadts_15)
 (enabled_if true)
 (modules gadts)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/high_arity.ml
 (name high_arity_15)
 (enabled_if true)
 (modules high_arity)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/int64_module.ml
 (name int64_module_15)
 (enabled_if true)
 (modules int64_module)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/int_module.ml
 (name int_module_15)
 (enabled_if true)
 (modules int_module)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/java_ffi.ml
 (name java_ffi_15)
 (enabled_if true)
 (modules java_ffi)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/java_ffi_ppx.ml
 (name java_ffi_ppx_15)
 (enabled_if true)
 (modules java_ffi_ppx)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/lazy_.ml
 (name lazy__15)
 (enabled_if true)
 (modules lazy_)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/linker.ml
 (name linker_15)
 (enabled_if true)
 (modules linker)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/lists.ml
 (name lists_15)
 (enabled_if true)
 (modules lists)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/method_size_limit.ml
 (name method_size_limit_15)
 (enabled_if true)
 (modules method_size_limit)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/method_split.ml
 (name method_split_15)
 (enabled_if true)
 (modules method_split)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/method_split_e2e.ml
 (name method_split_e2e_15)
 (enabled_if true)
 (modules method_split_e2e)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/modules.ml
 (name modules_15)
 (enabled_if true)
 (modules modules)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/mutex_cond.ml
 (name mutex_cond_15)
 (enabled_if true)
 (modules mutex_cond)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/number_strings.ml
 (name number_strings_15)
 (enabled_if true)
 (modules number_strings)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/obj_module.ml
 (name obj_module_15)
 (enabled_if true)
 (modules obj_module)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/prim_cost.ml
 (name prim_cost_15)
 (enabled_if true)
 (modules prim_cost)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/primitive_as_value.ml
 (name primitive_as_value_15)
 (enabled_if true)
 (modules primitive_as_value)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/pure_fun.ml
 (name pure_fun_15)
 (enabled_if true)
 (modules pure_fun)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/records.ml
 (name records_15)
 (enabled_if true)
 (modules records)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/refs.ml
 (name refs_15)
 (enabled_if true)
 (modules refs)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/source_map.ml
 (name source_map_15)
 (enabled_if true)
 (modules source_map)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/split_tree.ml
 (name split_tree_15)
 (enabled_if true)
 (modules split_tree)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/stdlib_link.ml
 (name stdlib_link_15)
 (enabled_if true)
 (modules stdlib_link)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/strings.ml
 (name strings_15)
 (enabled_if true)
 (modules strings)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/stub_registry_parse.ml
 (name stub_registry_parse_15)
 (enabled_if true)
 (modules stub_registry_parse)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/sys_module.ml
 (name sys_module_15)
 (enabled_if true)
 (modules sys_module)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/tuples_records_arrays.ml
 (name tuples_records_arrays_15)
 (enabled_if true)
 (modules tuples_records_arrays)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/user_stubs.ml
 (name user_stubs_15)
 (enabled_if true)
 (modules user_stubs)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))

(library
 ;; compiler/tests-compiler/variants.ml
 (name variants_15)
 (enabled_if true)
 (modules variants)
 (libraries unix str java_of_ocaml_expect_tests_helper)
 (inline_tests
  (enabled_if true))
 (flags (:standard -open Java_of_ocaml_expect_tests_helper))
 (preprocess
  (pps ppx_expect)))
