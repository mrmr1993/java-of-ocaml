This repository contains java-of-ocaml, a project for compiling OCaml bytecode to JVM bytecode.

This project relies heavily on the [OCaml compiler](https://github.com/ocaml/ocaml) and is strongly inspired by the WASM support provided by [`js_of_ocaml`](https://github.com/ocsigen/js_of_ocaml). Both are included as submodules for reference.

## Requirements

- OCaml 5.3.0+
- Dune 3.17+
- ppx_expect (for tests)
- A JDK (`java`, `javap`, `javac`) for compiling the runtime, running the output, and inspecting class files

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

The input is a full OCaml bytecode executable (as produced by `ocamlc`);
the output is a set of JVM `.class` files runnable on any Java
5-compatible JVM.

What works end-to-end (each covered by tests under
`compiler/tests-compiler/`):

- **Values & arithmetic** — ints (boxed as `java.lang.Integer`), the
  standard integer arithmetic, bitwise (`land`/`lor`/`lxor`/`lnot`),
  shifts (`lsl`/`lsr`/`asr`), unary negation, and all the comparisons
  (`=`/`<>`/`<`/`<=`/`>`/`>=`). Branches, let-bindings, if/else.
- **Strings** — OCaml strings flow as JVM `String`s.
- **Functions** — top-level and nested, single- and multi-arg
  (up to 7-ary), tail calls, non-tail calls (`PUSH_RETADDR`),
  recursion, mutually recursive functions (`CLOSUREREC` with
  `nfuncs > 1`), closures with captures, **partial application** via
  a runtime `PartialClosure` that defers application until saturated.
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
  MyExn -> ...` (specific matching via reference equality on
  exception descriptors). User-defined exceptions.
- **Modules** — structures, signatures (with opaque types / hidden
  internals), nested modules, aliases, `open`, local opens (`let open
  … in`, `M.(…)`), `include`, functors (single-arg, multi-arg
  curried, generative `()`), `with type` / destructive substitution
  (`with type :=`), `module type of`, first-class modules.
- **`Obj`** — the inlined externals (`Obj.repr`, `Obj.obj`,
  `Obj.magic`, `Obj.is_int`, `Obj.size`, `Obj.field`,
  `Obj.set_field`) plus the C primitives `Obj.tag`, `Obj.new_block`,
  `Obj.dup`, `Obj.with_tag`.
- **`Int`** — `neg`, `succ`/`pred`, `add`/`sub`/`mul`/`div`/`rem`,
  `logand`/`logor`/`logxor`, `shift_left`/`shift_right`/
  `shift_right_logical`, and the matching infix operators.
- **`Float`** — `+.` / `-.` / `*.` / `/.`, unary `-.`, `Float.abs`,
  NaN-safe float comparisons, `int_of_float` / `float_of_int`. Float
  values flow as JVM `double` (boxed to `java.lang.Double` when
  crossing into `Object`-typed args).
- **`Array`** — `Array.make`, `Array.length`, indexed access (`a.(i)`
  and `a.(i) <- v`, both the safe and unsafe externals),
  `caml_array_sub` / `caml_array_blit` / `caml_array_fill` /
  `caml_array_append`. The safe `Array.sub` / `Array.blit` / etc.
  wrappers in Stdlib fall through to `Stdlib.invalid_arg` on bad
  bounds, so tests bind the underlying externals directly until we
  can materialise `Invalid_argument`.

What doesn't work yet:

- No general `Stdlib` support — `print_endline`, `^`, `@`,
  `List.iter`, etc. would fall back to Stdlib's compiled bytecode,
  which isn't yet compiled. Tests use a handful of custom C
  primitives (`caml_java_print_int`, `caml_java_print_endline`)
  instead. Non-inlined `Obj` entry points like `Obj.is_block` follow
  the same path and are not yet supported.
- `module rec ... and ...` — needs `CamlinternalMod`'s lazy-
  initialised placeholders.
- `Lazy.t` / `lazy` / `Lazy.force`.
- IO, threads, effects, the GC.

## Layout

- `compiler/lib-java/` — the compiler library
  (`java_of_ocaml_compiler`). Bytecode reading, JVM class-file
  emission, the emit_* opcode handlers, and the compile driver.
- `compiler/bin-java_of_ocaml/` — the `java_of_ocaml.exe` CLI.
- `compiler/tests-compiler/` — ppx_expect tests, one file per topic
  (`arithmetic.ml`, `functions.ml`, `variants.ml`, `modules.ml`,
  ...). Each test compiles a short OCaml program through `ocamlc` →
  `java_of_ocaml.exe` → `java` and pins the stdout.
  `emission_snapshots.ml` pins `javap -c Main.class` output for
  representative programs.
- `compiler/tests-java_of_ocaml/`, `compiler/tests-full/` —
  additional test scaffolding.
- `runtime-java/` — Java sources for the runtime support classes
  (`Block`, `Closure`, `PartialClosure`, `CamlException`). `javac`
  compiles them at build time and the class bytes are embedded into
  the compiler.
- `ocaml/`, `js_of_ocaml/` — reference submodules, excluded from the
  dune build.
