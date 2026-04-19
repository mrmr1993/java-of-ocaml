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
`PartialClosure`, `CamlException`, `Channel`, `Bytes`, `Compare`, plus
one class per compiled OCaml function) into the output directory.

## Compilation pipeline

Input is a full OCaml bytecode executable (as produced by `ocamlc`);
output is a set of JVM `.class` files runnable on any Java 5-compatible
JVM.

The pipeline is a single pass with no legacy / fallback paths:

```
.bc file
  → Bytecode.read_exe             (CODE / PRIM / DATA / SYMB sections)
  → Instr.decode_all              (→ Instr.instr list)
  → Parse_bytecode.parse_{main,function}
                                  (→ Code.program: blocks, Var.t, conts)
  → Jvm_typing.infer              (per-Var Kind.kind lattice)
  → Jvm_generate.emit_program     (→ Jvm.Code.t per method)
  → Jvm.assemble_class            (→ .class bytes)
```

`Code.program` is an SSA-ish IR adapted from `js_of_ocaml/compiler/lib/
code.ml`: blocks with explicit `params`, straight-line instruction
bodies, and `last` terminators (Return / Raise / Stop / Branch / Cond /
Switch / Pushtrap / Poptrap). Every cross-block value flows through a
dedicated JVM local; block-edge parallel renames coerce each arg to the
target param's declared kind (convert-on-assign, same as jsoo's
lib-wasm/generate.ml).

## What's supported

Every feature listed below is exercised by at least one test under
`compiler/tests-compiler/`. `dune runtest` runs the whole suite.

- **Values & arithmetic** — ints (boxed as `java.lang.Integer` when
  passed to `Object`-typed args; primitive JVM `int` otherwise), the
  standard integer arithmetic, bitwise (`land` / `lor` / `lxor` /
  `lnot`), shifts (`lsl` / `lsr` / `asr`), unary negation, and all
  the comparisons (`=` / `<>` / `<` / `<=` / `>` / `>=`). Branches,
  let-bindings, if/else.
- **Strings** — OCaml strings flow as JVM `String`s.
- **Floats** — `+.` / `-.` / `*.` / `/.`, unary `-.`, `Float.abs`,
  NaN-safe float comparisons (via `dcmpl` / `dcmpg` chosen per
  operator), `int_of_float` / `float_of_int`. Floats flow as JVM
  `double`, boxed to `java.lang.Double` on crossing into
  `Object`-typed slots.
- **Functions** — top-level and nested, single- and multi-arg (up to
  7-ary), tail calls, non-tail calls, recursion, mutually recursive
  functions (`CLOSUREREC` with `nfuncs > 1`), closures with captures,
  partial application via a runtime `PartialClosure` that defers
  application until saturated.
- **Heap values** — tuples, records (including mutable fields),
  arrays (read / write / length), lists, deep constants from the
  `DATA` section (nested blocks materialised at `Main.main` entry
  by the globals-init prelude).
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
  internals), nested modules, aliases, `open`, local opens (`let
  open … in`, `M.(…)`), `include`, functors (single-arg, multi-arg
  curried, generative `()`), `with type` / destructive substitution
  (`with type :=`), `module type of`, first-class modules.
- **`Obj`** — the inlined externals (`Obj.repr`, `Obj.obj`,
  `Obj.magic`, `Obj.is_int`, `Obj.size`, `Obj.field`,
  `Obj.set_field`) plus the C primitives `Obj.tag`, `Obj.new_block`,
  `Obj.dup`, `Obj.with_tag`.
- **`Int`** — `neg`, `succ` / `pred`, `add` / `sub` / `mul` / `div`
  / `rem`, `logand` / `logor` / `logxor`, `shift_left` /
  `shift_right` / `shift_right_logical`, and the matching infix
  operators.
- **`Array`** — `Array.make`, `Array.length`, indexed access
  (`a.(i)` and `a.(i) <- v`, both the safe and unsafe externals),
  `caml_array_sub` / `caml_array_blit` / `caml_array_fill` /
  `caml_array_append`.
- **Stdlib primitives** — a broad set of C primitives is now
  implemented directly in the IR generator: string / bytes
  accessors, `caml_create_bytes`, `caml_blit_*`, `caml_ml_output*`
  / `caml_ml_flush`, the structural `caml_equal` / `caml_notequal`
  / `caml_compare` family, `caml_fresh_oo_id`, `caml_sys_get_config`
  / `caml_sys_const_*`, the full float arithmetic family,
  `caml_int_of_string` / `caml_format_int` / `caml_format_float`,
  OO-method dispatch stubs (`getmethod` / `getpubmet` /
  `getdynmet`), and many more. Unrecognised primitives compile to a
  runtime-throwing stub so the class loads cleanly.

## What doesn't work yet

- **Full `Stdlib` module record materialisation** — some non-inlined
  Stdlib functions (`Obj.is_block`, parts of `Printf`) route through
  a global module record we don't yet materialise.
- `module rec … and …` — partial (tests under `corecursion.ml` pass;
  deeper patterns via `CamlinternalMod` still hit edge cases).
- `Lazy.t` / `lazy` / `Lazy.force`.
- I/O beyond stdout, threads, OCaml 5 effects, the GC.
- Method bodies over the JVM's signed 16-bit branch-offset limit
  (~32 KB of bytecode per method) — currently rejected at class-file
  assembly time. Deep Stdlib internals (`Marshal`, deep `Printf`
  routing) can exceed this.

## Layout

- `compiler/lib-java/` — the compiler library
  (`java_of_ocaml_compiler`).
  - **Input**: `bytecode` (executable reader), `instr` (decoded
    instructions with branch-target arithmetic), `global_view`
    (DATA-section classification), `prim` (C primitive registry).
  - **IR**: `code` (`Var.t`, `expr`, `instr`, `last`, `block`,
    `program`), `parse_bytecode` (bytecode → IR).
  - **Types & generation**: `kind` (per-value kind lattice),
    `jvm_typing` (per-Var forward kind inference), `jvm_generate`
    (IR → JVM bytecode).
  - **JVM output**: `jvm_bin` / `jvm_constant_pool` / `jvm_code` /
    `jvm_class_file` (class-file construction), `jvm_runtime`
    (pre-compiled runtime-class bytes).
  - **Driver**: `compile.ml` wires everything together, plus
    `function_info`, `debug`, `timer`.
- `compiler/bin-java_of_ocaml/` — the `java_of_ocaml.exe` CLI.
- `compiler/tests-compiler/` — ppx_expect tests, one file per topic
  (`arithmetic.ml`, `functions.ml`, `variants.ml`, `modules.ml`,
  `exceptions.ml`, `lists.ml`, `corecursion.ml`, `high_arity.ml`,
  `gadts.ml`, `extensible.ml`, `records.ml`, `refs.ml`,
  `strings.ml`, `tuples_records_arrays.ml`, `bytecode_smoke.ml`,
  `float_module.ml`, `int_module.ml`, `number_strings.ml`,
  `obj_module.ml`, `array_module.ml`). Each test compiles a short
  OCaml program through `ocamlc` → `java_of_ocaml.exe` → `java` and
  pins the stdout. `emission_snapshots.ml` pins `javap -c
  Main.class` output for representative programs.
- `compiler/tests-java_of_ocaml/`, `compiler/tests-full/` —
  additional test scaffolding.
- `runtime-java/` — Java sources for the runtime support classes
  (`Block`, `Closure`, `PartialClosure`, `CamlException`, `Channel`,
  `Bytes`, `Compare`). `javac` compiles them at build time and the
  class bytes are embedded into the compiler.
- `ocaml/`, `js_of_ocaml/` — reference submodules, excluded from the
  dune build.
- `docs/ALIGNMENT.md` — index of remaining structural/API alignments
  with jsoo.
