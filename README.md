This repository contains java-of-ocaml, a project for compiling OCaml bytecode to JVM bytecode.

This project relies heavily on the [OCaml compiler](https://github.com/ocaml/ocaml) and is strongly inspired by the WASM support provided by [`js_of_ocaml`](https://github.com/ocsigen/js_of_ocaml). Both are included as submodules for reference.

## Requirements

- OCaml 5.3.0+
- Dune 3.17+
- ppx_expect (for tests)
- A JDK (`java`, `javap`) for running compiled output and inspecting class files

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

## Using the compiler

```bash
ocamlc -no-check-prims -g prog.ml -o prog.bc
_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe prog.bc -o out_dir
java -cp out_dir Main
```

The compiler writes a set of `.class` files (`Main`, `Block`, `Closure`,
`PartialClosure`, `CamlException`, plus one class per compiled OCaml
function) into the output directory.

## Project status

The compiler handles a substantial fragment of OCaml. The input is a
full OCaml bytecode executable (as produced by `ocamlc`); the output
is a set of JVM `.class` files runnable on any Java 5-compatible JVM.

Roughly, what works end-to-end (all covered by `compiler/tests-compiler/end_to_end.ml`):

- **Values & arithmetic** — ints (boxed as `java.lang.Integer`), the
  standard integer arithmetic and comparisons, branches, let-bindings,
  if/else.
- **Strings** — OCaml strings flow as JVM `String`s.
- **Functions** — top-level and nested, single- and multi-arg
  (up to 7-ary), tail calls, non-tail calls (`PUSH_RETADDR`),
  recursion, mutually recursive functions (`CLOSUREREC` with `nfuncs > 1`),
  closures with captures, **partial application** via a runtime
  `PartialClosure` that defers application until saturated.
- **Heap values** — tuples, records (including mutable fields),
  arrays (read/write/length), lists, deep constants from the `DATA`
  section (nested blocks materialised at load-time).
- **Variants** — option, enum-only, mixed immediate/data, inline
  records inside variant constructors, polymorphic variants, GADTs,
  extensible variant types (`type t = ..` / `type t += A | B`).
- **Mutable state** — `ref`, `:=`, `!`, `incr`, `decr`.
- **Recursive values** — `let rec a = A (b, b) and b = [|a; a; a|]`
  via `caml_alloc_dummy` / `caml_update_dummy`.
- **Exceptions** — `raise`, `try ... with _ -> ...`, `try ... with
  MyExn -> ...` (specific matching via reference equality on exception
  descriptors). User-defined exceptions.
- **Modules** — structures, signatures (with opaque types / hidden
  internals), nested modules, aliases, `open`, local opens (`let open …
  in`, `M.(…)`), `include`, functors (single-arg, multi-arg curried,
  generative `()`), `with type` / destructive substitution (`with type
  :=`), `module type of`, first-class modules.

What doesn't work yet:

- No `Stdlib` support — `print_endline`, `^`, `@`, `List.iter`, etc.
  all fall back to Stdlib's compiled bytecode, which we don't yet
  compile. Tests use a handful of custom C primitives
  (`caml_java_print_int`, `caml_java_print_endline`) instead.
- `module rec ... and ...` — needs `CamlinternalMod`'s lazy-
  initialised placeholders.
- `Lazy.t` / `lazy` / `Lazy.force` — needs `Obj` module support
  first.
- Floats.
- IO, threads, effects, the GC.

## Layout

- `compiler/lib-java/` — the compiler library.
    - `bytecode.{ml,mli}` — reads OCaml bytecode executables (CODE,
      PRIM, DATA, SYMB sections).
    - `jvm.{ml,mli}` — emits JVM class files (constant pool, method
      bodies, exception tables, the runtime helper classes `Block` /
      `Closure` / `PartialClosure` / `CamlException`).
    - `compile.{ml,mli}` — the driver: identifies the user bytecode
      range, tracks OCaml-stack slots and kinds, emits JVM code for
      each supported opcode, and generates one class per OCaml
      function.
- `compiler/bin-java_of_ocaml/` — the `java_of_ocaml.exe` CLI.
- `compiler/tests-compiler/` — `ppx_expect` end-to-end tests
  (`end_to_end.ml` has 99 of them at the moment, each running a
  short OCaml program through `ocamlc` → `java_of_ocaml.exe` →
  `java` and pinning the expected stdout).
- `compiler/tests-java_of_ocaml/`, `compiler/tests-full/` — additional
  test scaffolding.
- `ocaml/`, `js_of_ocaml/` — reference submodules, excluded from the
  dune build.
