
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
