This repository contains java-of-ocaml, a project for compiling OCaml bytecode to JVM bytecode.

This project relies heavily on the [OCaml compiler](https://github.com/ocaml/ocaml) and is strongly inspired by the WASM support provided by [`js_of_ocaml`](https://github.com/ocsigen/js_of_ocaml). Both are included as submodules for reference.

## Requirements

- OCaml 5.3.0+
- Dune 3.17+
- ppx_expect (for tests)

## Setup

```bash
opam switch create . ocaml-base-compiler.5.3.0 --no-install
eval $(opam env)
opam install ppx_expect dune
```

## Building and Testing

```bash
dune build @all    # Build everything
dune runtest       # Run all tests
dune promote       # Accept test output changes
```

## Project Status

The compiler does not yet exist. The repository currently contains:
- Test infrastructure mirroring js_of_ocaml's patterns, ready for the compiler to be plugged in
- Reference submodules (`ocaml/`, `js_of_ocaml/`) for the OCaml compiler and js_of_ocaml/wasm_of_ocaml
