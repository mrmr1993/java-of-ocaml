(lang dune 3.17)

(name java_of_ocaml)

(generate_opam_files true)

(package
 (name java_of_ocaml)
 (synopsis "Compiler from OCaml bytecode to JVM bytecode")
 (allow_empty)
 (depends
  (ocaml (>= 4.14))
  (cmdliner (>= 1.1.0))
  (yojson (>= 2.0))
  (ppx_expect
   (and
    (>= v0.16.1)
    :with-test))))
