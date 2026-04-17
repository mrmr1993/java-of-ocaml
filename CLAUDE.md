# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**java-of-ocaml** is a project for compiling OCaml bytecode to JVM bytecode. It is modeled after `wasm_of_ocaml` (the WASM backend in `js_of_ocaml`), which compiles OCaml bytecode to WebAssembly.

The project uses a local opam switch with OCaml 5.3.0 and dune 3.17. The compiler does not yet exist — the repository currently contains test infrastructure and two reference submodules:
- `ocaml/` — the OCaml compiler (pinned near 4.12.0-alpha1)
- `js_of_ocaml/` — the js_of_ocaml/wasm_of_ocaml compiler (pinned near 6.3.0)

These submodules are excluded from the dune build (via the root `dune` file) and are for reference only.

## Build & Test Commands

```bash
dune build @all                            # Build everything
dune runtest                               # Run all tests
dune runtest compiler/tests-java_of_ocaml  # Standalone executable tests (byte mode)
dune runtest compiler/tests-compiler       # ppx_expect inline tests
dune runtest compiler/tests-full           # Library compilation tests
dune promote                               # Accept test output changes
```

## Test Infrastructure

The test infrastructure mirrors js_of_ocaml's patterns (see `js_of_ocaml/compiler/tests-compiler/util/`).

- **`compiler/tests-compiler/util/`** — Test helper library (`java_of_ocaml_expect_tests_helper`). Provides `compile_ocaml_to_cmo`, `compile_ocaml_to_bc`, `compile_lib`, `compile_bc_to_class`, `run_java`, `compile_and_run`, `with_temp_dir`. The JVM compilation functions reference the future `compiler/bin-java_of_ocaml/java_of_ocaml.exe` binary.
- **`compiler/tests-compiler/`** — ppx_expect inline tests. New `.ml` files are auto-discovered by `gen-rules/gen.ml` which generates `dune.inc`. Run `dune promote` after adding new test files to update `dune.inc`.
- **`compiler/tests-java_of_ocaml/`** — Standalone executable tests with `.expected` output files. Currently runs in `byte` mode; will switch to `(modes byte java)` when the dune mode plugin is built.
- **`compiler/tests-full/`** — Library compilation tests. Defines OCaml libraries and (eventually) compiles them to JVM output for golden-file comparison.

## Architecture & Approach

The intended compilation pipeline (following wasm_of_ocaml's pattern) is:
1. Read OCaml bytecode (`.cmo`/`.cma` files produced by `ocamlc`)
2. Convert to an intermediate representation
3. Optimize and transform
4. Generate JVM bytecode (`.class` files) or JAR output

### Key reference code in the submodules

- **wasm_of_ocaml backend** (`js_of_ocaml/compiler/lib-wasm/`): The primary architectural reference. Contains WASM code generation (`code_generation.ml`), closure conversion (`closure_conversion.ml`), tail call handling (`tail_call.ml`), GC targeting (`gc_target.ml`), linking (`link.ml`, `wasm_link.ml`), and AST/output (`wasm_ast.ml`, `wasm_output.ml`, `wat_output.ml`).
- **js_of_ocaml shared compiler lib** (`js_of_ocaml/compiler/lib/`): Bytecode parsing (`parse_bytecode.ml`), internal IR (`code.ml`), and the compilation driver (`driver.ml`) are shared infrastructure.
- **OCaml bytecode compiler** (`ocaml/bytecomp/`): The bytecode generation and instruction set (`instruct.ml`, `bytegen.ml`, `emitcode.ml`) that defines the input format.

### JVM-specific considerations vs WASM

- JVM has a typed operand stack and structured method calls rather than WASM's linear memory + GC extension
- JVM requires class file format output rather than WASM binary/text format
- JVM tail calls need trampolining or similar strategies (no native tail-call support like WASM)
- OCaml value representation must map to JVM object model (boxed types, tagged integers, etc.)
