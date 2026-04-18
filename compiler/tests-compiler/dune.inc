
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
