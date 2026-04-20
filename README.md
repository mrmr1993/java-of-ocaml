This repository contains java-of-ocaml, a project for compiling OCaml bytecode to JVM bytecode.

This project relies heavily on the [OCaml compiler](https://github.com/ocaml/ocaml) and is strongly inspired by the WASM support provided by [`js_of_ocaml`](https://github.com/ocsigen/js_of_ocaml). Both are included as submodules for reference.

## Requirements

- OCaml 5.3.0 (primary) or 4.14.2 (for consuming 4.14-built bytecode)
- Dune 3.17+
- `ppx_expect` (for tests)
- A JDK (`java`, `javap`, `javac`) for compiling the runtime, running the output, and inspecting class files

The compiler builds under either compiler version. A tiny
[`bytecode_compat`](compiler/lib-java/bytecode_compat.mli) shim,
selected at build time by `%{ocaml_version}`, normalises 4.14's and
5.x's incompatible `Cmo_format` variants into one shape. Build under
4.14 when you need to ingest bytecode produced by 4.14-pinned
projects; build under 5.x for everything else.

## Setup

```bash
opam switch create . ocaml-base-compiler.5.3.0 --no-install
eval $(opam env)
opam install ppx_expect dune
```

For the optional 4.14 switch (used to ingest 4.14-built bytecode):

```bash
opam switch create ./.opam-4.14 4.14.2 --no-install
eval $(opam env --switch=./.opam-4.14)
opam install dune cmdliner
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

Input can also be a list of `.cmo` / `.cma` files (e.g. `stdlib.cma
user.cmo`); the linker concatenates their code sections and resolves
relocations in-process.

The compiler writes `Main.class`, the runtime support classes
(`Block`, `Closure`, `PartialClosure`, `CamlException`, `Channel`,
`Bytes`, `Compare`, `BigArray`, `Mutex`, `CondVar`, `ThreadPrim`,
`JavaFFI`, ...), and one class per compiled OCaml function into the
output directory.

### Useful CLI flags

- `-o DIR` — output directory (required).
- `--debug FLAG` — enable a named debug trace (comma-separated or
  repeat the flag). Equivalent to adding the flag name to
  `JAVA_OF_OCAML_DEBUG`. Common traces: `times`, `times_detail`,
  `primitives`, `functions`, `ir_emit`, `ir_trace`, `ir_gen_trace`,
  `split_times`, `split`, `deadcode`, `eval`.
- `--print-function PC` — dump the decoded bytecode for the function
  body at that PC. Repeatable.
- `--print-ir PC` — dump the `Code.program` produced by the parser
  for the function body at that PC (or the failure message if IR
  lowering couldn't handle it).
- `--list-missing-prims` — don't compile; instead list every C
  primitive referenced by the input that the backend has no
  explicit handler for (those compile to runtime-throwing stubs).
  Useful for planning coverage work on unfamiliar codebases.

### Performance note for large programs

For inputs in the hundreds-of-MB range (thousands of compiled
compilation units), raising the OCaml minor-heap size and
space-overhead substantially reduces compile time:

```bash
OCAMLRUNPARAM='s=32M,o=300' _build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe ...
```

## Compilation pipeline

Input is either a full OCaml bytecode executable (as produced by
`ocamlc`) or a set of `.cmo` / `.cma` files to link; output is a set
of JVM `.class` files runnable on any Java 5-compatible JVM.

The pipeline is a single pass with no legacy / fallback paths:

```
.bc / .cmo / .cma
  → Bytecode.read_exe / Linker.link
                                  (CODE / PRIM / DATA / SYMB + reloc)
  → Instr.decode_all              (→ Instr.instr array)
  → Parse_bytecode.parse_{main,function}
                                  (→ Code.program: blocks, Var.t, conts)
  → Eval + Deadcode (optional)    (→ Code.program)
  → Jvm_typing.infer              (per-Var Kind.kind)
  → Method_split.split            (if the method would exceed 64 KB)
  → Jvm_generate.emit_program     (→ Jvm.Code.t per method)
  → Jvm.assemble_class            (→ .class bytes)
```

`Code.program` is a strict-SSA IR adapted from `js_of_ocaml/compiler/
lib/code.ml`: blocks with explicit `params`, straight-line instruction
bodies (`Let` / `Set_field` / `Offset_ref` / `Array_set` /
`Source_pc`), and `last` terminators (`Return` / `Raise` / `Stop` /
`Branch` / `Cond` / `Switch` / `Pushtrap` / `Poptrap` /
`Invoke_tail`). Every `Var.t` has exactly one definition (no
`Assign`; OCaml bytecode's `ASSIGN` is handled by reseating the
parser's stack slot). Every cross-block value flows through a
dedicated JVM local; block-edge parallel renames coerce each arg to
a caller param's declared kind (convert-on-assign, same as jsoo's
`lib-wasm/generate.ml`).

Two analyses stand out:
- **`Code.compute_trap_contexts`** derives the stack of active
  `Pushtrap` blocks at every reachable block entry by forward DFS
  from `prog.start`. Both `Method_split` (cut-region validation) and
  `Jvm_generate` (JVM exception-table entries) consume the resulting
  map so that nested try/with is laid out correctly even after
  structural splits.
- **`Method_split.split`** carves programs whose emitted bytecode
  would exceed the JVM's 64 KB `Code`-attribute limit into a head
  method plus `Invoke_tail` helper methods. It combines an
  intra-block chunker (for individually oversized blocks) with a
  CFG cut-point search; cuts are validated against trap regions so
  split boundaries never bisect a protected region.

## What's supported

Every feature below is exercised by at least one test under
`compiler/tests-compiler/`. `dune runtest` runs the whole suite.

- **Values & arithmetic** — ints (primitive JVM `int` where possible;
  boxed as `java.lang.Integer` across `Object` boundaries), the
  standard integer arithmetic, bitwise, shifts, and comparisons.
  Branches, let-bindings, if/else.
- **Strings** — OCaml strings flow as JVM `String`.
- **Floats** — full float arithmetic, NaN-safe comparisons,
  `int_of_float` / `float_of_int`. Floats flow as JVM `double`,
  boxed to `java.lang.Double` on `Object` crossings. 2-wide locals.
- **`Int64` / `Nativeint`** — bit-accurate 64-bit arithmetic via
  native JVM `long` ops; boxed as `java.lang.Long`.
- **Functions** — top-level and nested, up to 7-ary, tail calls,
  recursion, mutual recursion (`CLOSUREREC`), closures with
  captures, partial application via a runtime `PartialClosure`.
- **Heap values** — tuples, records (including mutable fields),
  arrays, lists, deep DATA-section constants (materialised at
  `Main.main` entry by the globals-init prelude).
- **Variants** — option, enum-only, mixed immediate/data, inline
  records inside variant constructors, polymorphic variants, GADTs,
  extensible variant types (`type t = ..` / `type t += A | B`).
- **Mutable state** — `ref`, `:=`, `!`, `incr`, `decr`.
- **Recursive values** — `let rec a = A (b, b) and b = [|a; a; a|]`
  via `caml_alloc_dummy` / `caml_update_dummy`.
- **Exceptions** — `raise`, `try ... with _ -> ...`, matching on
  specific exception constructors (via reference equality on
  descriptors). User-defined exceptions; nested try/with with
  correct stack-relative trap semantics.
- **Modules** — structures, signatures, nested modules, aliases,
  `open` (top-level and local), `include`, functors (single-arg,
  multi-arg curried, generative `()`), `with type` / destructive
  substitution, `module type of`, first-class modules.
- **`Lazy`** — `lazy expr` and `Lazy.force` round-trip through
  `CamlinternalLazy` plus the four tag-transition primitives.
- **`Obj`** — the inlined externals plus the C primitives
  `Obj.tag`, `Obj.new_block`, `Obj.dup`, `Obj.with_tag`.
- **`Array` / `Bigarray`** — `Array.make`, `Array.length`, safe and
  unsafe indexed access, `caml_array_*`. `Array1` / `Array2` /
  `Genarray` via a `BigArray` runtime class (boxed storage per
  cell; handles any kind/layout combination).
- **I/O** — `print_*`, `open_in` / `open_out`, `input_char` /
  `input_line` / `input` / `close_in` / `close_out`, `Sys.remove`
  via `caml_sys_open` / `caml_sys_close` / `caml_ml_input*` /
  `caml_ml_output*`, backed by a `Channel` runtime class wrapping
  `java.io.PrintStream` / a 64 KB buffered input.
- **String concat** (`^`) via a `Bytes` runtime class
  (`StringBuilder` wrapper).
- **`Mutex` / `Condition` / `Thread`** — backed by
  `java.util.concurrent.locks.ReentrantLock`, `java.lang.Thread`, and
  a lazily-bound `Condition`. Low-level primitives + `threads.cma`'s
  OCaml-side API both work; `Unix`-init stubs pulled in by
  `threads.cma` are satisfied.
- **`Digest`** — `Digest.string` / `bytes` via
  `java.security.MessageDigest`.
- **`Random`** — `Random.State.*`, stdlib's `Random` (uses the
  4-int64 `BigArray` state advanced by `caml_lxm_next`).
- **Java FFI** — user-declared `external f : ... =
  "java:<op>:..."` primitives emit direct `invoke*` / `getfield` /
  `new` sequences. The `Java` library adds phantom-typed wrappers +
  `Java.Unsafe`; `ppx_java` adds `obj##meth` /
  `[%java.new]` / `[%java.static]` / `[%java.get]` / `[%java.set]`
  sugar that expands to calls through the reflective `JavaFFI`
  runtime class.
- **`.cmo` / `.cma` linking** — multi-input linking concatenates
  code sections, resolves relocations, and emits a trailing `STOP`
  so the linked program behaves like a unified bytecode executable.
- **Method splitting** — methods whose emitted body would exceed
  the JVM's 64 KB `Code` limit are automatically split into a head
  method plus `Invoke_tail` helpers. No user action required.
- **Source-line debug info** — `LineNumberTable` populated at
  per-bytecode-instruction granularity via the `Source_pc`
  pseudo-instruction.
- **Structural comparison** — `caml_equal`, `caml_compare`, and
  friends route through a `Compare` runtime class.
- **Stdlib primitives** — a broad set of C primitives implemented
  directly in the IR generator (system constants, string/bytes,
  I/O, comparisons, OO-method dispatch, float formatting, ...).
  Unrecognised primitives compile to a runtime-throwing
  `UnsupportedOperationException` stub so the class loads cleanly.

## What doesn't work yet

- **Full `Stdlib` module record materialisation** — some non-inlined
  Stdlib functions (`Obj.is_block`, parts of `Printf`) route through
  a global module record we don't yet materialise unless linking
  against `stdlib.cma`.
- `module rec … and …` — simple cases pass (`corecursion.ml`);
  deeper patterns via `CamlinternalMod` still hit edge cases.
- **OCaml 5 effects** — no support.
- **Real GC** — the JVM does the GC; there is no OCaml-style
  memory-allocator bridge.
- Plain OCaml `int` runs as a JVM 32-bit `int` rather than OCaml's
  native 63-bit; bitwise / overflow-sensitive code that relies on
  the full width will diverge. `Int64` / `Nativeint` are
  bit-accurate.

## Layout

- `compiler/lib-java/` — the compiler library
  (`java_of_ocaml_compiler`).
  - **Input**: `bytecode` (executable reader), `bytecode_compat`
    (4.14 / 5.x `Cmo_format` shim), `linker` (`.cmo` / `.cma`
    linking), `instr` (decoded instructions + branch-target
    arithmetic), `global_view` (DATA-section classification),
    `prim` (C primitive registry), `function_info`.
  - **IR**: `code` (`Var.t`, `expr`, `instr`, `last`, `block`,
    `program`, `compute_trap_contexts`), `parse_bytecode`
    (bytecode → IR), `eval`, `deadcode`, `pure_fun`,
    `method_split`, `code_cost`.
  - **Types & generation**: `kind` (per-value kind lattice),
    `jvm_typing` (per-Var forward kind inference), `jvm_generate`
    (IR → JVM bytecode).
  - **JVM output**: `jvm_bin` / `jvm_constant_pool` / `jvm_code` /
    `jvm_class_file` (class-file construction), `jvm_runtime`
    (pre-compiled runtime-class bytes).
  - **Driver / pretty-printing**: `compile`, `print_ir`,
    `print_function`, `debug`, `timer`.
- `compiler/bin-java_of_ocaml/` — the `java_of_ocaml.exe` CLI.
- `compiler/tests-compiler/` — ppx_expect tests. One file per
  topic (`arithmetic.ml`, `functions.ml`, `variants.ml`,
  `modules.ml`, `exceptions.ml`, `lists.ml`, `corecursion.ml`,
  `high_arity.ml`, `gadts.ml`, `extensible.ml`, `records.ml`,
  `refs.ml`, `strings.ml`, `tuples_records_arrays.ml`,
  `bytecode_smoke.ml`, `float_module.ml`, `int_module.ml`,
  `int64_module.ml`, `number_strings.ml`, `obj_module.ml`,
  `array_module.ml`, `bigarray_module.ml`, `ephemeron.ml`,
  `file_io.ml`, `lazy_.ml`, `mutex_cond.ml`, `primitive_as_value.ml`,
  `source_map.ml`, `sys_module.ml`, `java_ffi.ml`,
  `java_ffi_ppx.ml`, `method_split.ml`, `method_split_e2e.ml`,
  `method_size_limit.ml`, `branch_relaxation.ml`, `stdlib_link.ml`,
  `linker.ml`, `cmo_reader.ml`, `eval.ml`, `deadcode.ml`,
  `pure_fun.ml`). `emission_snapshots.ml` pins `javap -c
  Main.class` output for representative programs.
- `compiler/tests-java_of_ocaml/`, `compiler/tests-full/` —
  additional test scaffolding.
- `runtime-java/` — Java sources for the runtime support classes.
  `javac` compiles them at build time and the class bytes are
  embedded into the compiler.
- `ppx/ppx_java/` — the `ppx_java` extension providing
  `obj##meth` / `[%java.new]` / `[%java.static]` / etc. sugar.
- `ocaml/`, `js_of_ocaml/` — reference submodules, excluded from
  the dune build.
- `docs/ALIGNMENT.md` — index of remaining structural/API alignments
  with jsoo.
