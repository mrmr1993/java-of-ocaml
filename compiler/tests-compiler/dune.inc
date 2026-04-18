
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
 ;; compiler/tests-compiler/end_to_end.ml
 (name end_to_end_15)
 (enabled_if true)
 (modules end_to_end)
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
