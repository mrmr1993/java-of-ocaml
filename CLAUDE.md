# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**java-of-ocaml** compiles OCaml bytecode executables (as produced by
`ocamlc`) to JVM class files. It is modeled after `wasm_of_ocaml` (the
WASM backend in `js_of_ocaml`), which compiles OCaml bytecode to
WebAssembly.

The project uses a local opam switch with OCaml 5.3.0 and dune 3.17.

### What's actually implemented

The compiler is a real working compiler (not a scaffold). The
end-to-end test suite in `compiler/tests-compiler/end_to_end.ml` has
~99 tests each of the form "compile this OCaml program, run the
resulting JVM output, assert the stdout matches". Every feature
listed below is covered by at least one of those tests. `dune
runtest` runs the whole thing.

Working:

- **Values** — ints (boxed as `java.lang.Integer` when passed to
  `Object`-typed args; unboxed at point of use), strings (flow as JVM
  `String`), tuples, records (mutable and immutable), arrays, lists,
  refs, variants (option, enum, mixed immediate/data, polymorphic,
  extensible via `type t = ..`), GADTs, inline records in variants.
- **Control flow** — if/else, branches, `for`, `while`, tail calls,
  exceptions (`raise` + `try ... with _`, or matching specific
  exceptions via reference equality on descriptors).
- **Functions** — up to 7-ary, non-tail calls (`PUSH_RETADDR`),
  recursion, mutual recursion (`CLOSUREREC` with `nfuncs > 1`),
  closures capturing anything, partial application (undersupplied
  calls produce a `PartialClosure` that delays until saturation).
- **Modules** — structures, signatures, nested modules, aliases,
  `open` (top-level and local), functors (single-arg, multi-arg
  curried, generative `()`), `include`, `with type` and `with type
  :=`, `module type of`, first-class modules. See "module-features
  survey" tests in `end_to_end.ml`.
- **Recursive values** — `let rec a = A (b, b) and b = [|a; a; a|]`
  via `caml_alloc_dummy` / `caml_update_dummy`.

Not yet supported:

- No `Stdlib` — e.g. `print_endline`, `^`, `@`, `List.iter`, etc.
  all fall back to Stdlib's compiled bytecode, which we don't
  compile. Tests use custom C primitives
  (`caml_java_print_int`, `caml_java_print_endline`) for output.
- `module rec` — OCaml lowers these via `CamlinternalMod`'s
  lazy-initialised placeholders.
- `Lazy.t` / `lazy` / `Lazy.force`.
- Floats, IO, threads, effects.

The user has asked to defer `Obj` and `Lazy` until later.

### Reference submodules

- `ocaml/` — the OCaml compiler (pinned near 4.12.0-alpha1)
- `js_of_ocaml/` — the js_of_ocaml/wasm_of_ocaml compiler (pinned
  near 6.3.0)

Both are excluded from the dune build (via the root `dune` file) and
are for reference only.

## Build & test commands

```bash
dune build @all                            # Build everything
dune runtest                               # Run all tests (full suite)
dune runtest compiler/tests-compiler       # The main ppx_expect end-to-end suite
dune runtest compiler/tests-java_of_ocaml  # Standalone executable tests (byte mode)
dune runtest compiler/tests-full           # Library compilation tests
dune promote                               # Accept test output changes
```

To compile an OCaml program through the pipeline manually:

```bash
ocamlc -no-check-prims -g prog.ml -o prog.bc
_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe prog.bc -o out_dir
java -cp out_dir Main
```

## Repository layout

- `compiler/lib-java/` — the compiler library (`java_of_ocaml_compiler`).
    - `bytecode.{ml,mli}` — bytecode-executable reader. Decodes
      CODE, PRIM, DATA, SYMB sections. `SYMB` parsing goes through
      `compiler-libs.bytecomp`'s `Symtable.global_map` (do NOT
      re-implement via `Obj` traversal — user feedback asked
      specifically for compiler-libs here).
    - `jvm.{ml,mli}` — class-file emitter. Writes bytes by hand (no
      `javalib` dependency). Tracks `max_stack` / `max_locals`
      linearly — this is straight-line code only, so a dangling `pop`
      after a `goto` silently desyncs the tracker (see
      `emit_int_case_chain` et al for workarounds using stashed
      locals). Runtime helper classes generated from here:
      `Block` (heap block with mutable-ish `tag` + `Object[] fields`),
      `Closure` (base class; `applyN` dispatches via `arity()` to
      subclass's concrete method, or builds a `PartialClosure`),
      `PartialClosure` (captures a target + args, builds deeper
      partials or dispatches once saturated), `CamlException`
      (wraps the thrown OCaml value, extends `RuntimeException`).
    - `compile.{ml,mli}` — the driver. Locates the user range via
      seed primitives (`caml_java_print_*`, array ops — NOT
      `caml_fresh_oo_id`, which also appears in Stdlib init), walks
      the bytecode instruction-by-instruction, tracks OCaml-stack
      slots + kinds, emits per-instruction JVM code, and generates
      one class per OCaml function.
- `compiler/bin-java_of_ocaml/` — the `java_of_ocaml.exe` CLI binary
  (thin wrapper around `Compile.compile`).
- `compiler/tests-compiler/` — ppx_expect end-to-end tests. New
  test files in this directory are auto-discovered by
  `gen-rules/gen.ml` which generates `dune.inc`. Run `dune promote`
  after adding new test files.
- `compiler/tests-compiler/util/` — test helpers
  (`java_of_ocaml_expect_tests_helper`). Key function:
  `compile_and_run s` writes `s` to `test.ml`, runs it through
  `ocamlc` → `java_of_ocaml.exe` → `java`, and prints stdout. Almost
  every test uses this.
- `compiler/tests-java_of_ocaml/` — standalone executable tests with
  `.expected` output files. Currently runs in `byte` mode only; the
  commented-out `java` mode is aspirational pending a real dune
  plugin.
- `compiler/tests-full/` — library compilation tests. Currently
  mostly placeholder.

## Kind-tracking model

The compiler uses a small `kind` enum to track what each OCaml-stack
slot or the accumulator holds at compile time, and where JVM `int`
boxing/unboxing needs to happen:

```ocaml
type kind =
  | K_int            (* primitive JVM [int] *)
  | K_string         (* JVM [java.lang.String] *)
  | K_block of kind list  (* [Block] with known field kinds *)
  | K_closure of closure_ref
  | K_obj            (* opaque — resolved lazily at point of use *)
```

`K_obj` is the escape hatch. Apply-method parameters always arrive as
`K_obj` (we don't do whole-program arg-kind inference) and get cast /
unboxed via `ensure_kind state target` at each use. Return kinds are
inferred by a pre-pass (`classify_return_kind_at`): K_int only for
known int-producing ops (`CONST*`, arithmetic, comparisons, ...);
K_obj for everything else (including `ACC` / `ENVACC` / `APPLY`).

When a feature is failing with "APPLY called on a non-closure value"
or "GETFIELD on non-block" — the likely cause is `ensure_kind` not
being called on some new code path. Each pattern-matching branch,
each opcode that reads acc, has to decide whether acc's current
`kind` matches what it wants and unbox if not.

## Stacks to be aware of

1. **OCaml bytecode stack** — modeled by `state.slots`,
   `state.oc_stack_depth`. Each slot records a kind + the JVM local
   holding the pushed value.
2. **JVM operand stack** — tracked by `jvm.ml`'s `push`/`pop`
   accounting. Straight-line only — be careful with `dup` + `pop` on
   paths after a `goto`.
3. **The JVM local-variable table** — `state.next_local` is monotonic
   (we never reuse locals across push/pop; closures capture by JVM
   local, and reusing a local would clobber a live capture).

## JVM-specific considerations vs WASM

- JVM has a typed operand stack and structured method calls rather
  than WASM's linear memory + GC extension.
- JVM tail calls are not native — the OCaml `APPTERM` family compiles
  to `invokevirtual` + `areturn` (no TCO, but the JIT often handles
  it).
- OCaml value representation maps to the JVM object model:
  - ints → `java.lang.Integer` (boxed when crossing into `Object`-
    typed args).
  - strings → `java.lang.String`.
  - heap blocks → `Block` (`int tag` + `Object[] fields`).
  - closures → `Closure` subclasses (one class per source-level
    function).
- Class files are emitted with Java major version 49 (Java 5). This
  uses the old type-inference verifier; if we ever need the newer
  strict verifier (Java 6+), we'll need to emit `StackMapTable`
  attributes.

## Reference code in the submodules

- **wasm_of_ocaml backend** (`js_of_ocaml/compiler/lib-wasm/`) — the
  primary architectural reference. Contains WASM code generation
  (`code_generation.ml`), closure conversion
  (`closure_conversion.ml`), tail call handling (`tail_call.ml`), GC
  targeting (`gc_target.ml`), linking (`link.ml`, `wasm_link.ml`),
  and AST/output (`wasm_ast.ml`, `wasm_output.ml`, `wat_output.ml`).
- **js_of_ocaml shared compiler lib** (`js_of_ocaml/compiler/lib/`) —
  bytecode parsing (`parse_bytecode.ml`), internal IR (`code.ml`),
  and the compilation driver (`driver.ml`) are shared infrastructure.
- **OCaml bytecode compiler** (`ocaml/bytecomp/`) — the bytecode
  generation and instruction set (`instruct.ml`, `bytegen.ml`,
  `emitcode.ml`) that defines the input format.

## Working conventions

- Commit messages follow `Phase N step M: <headline>` with a body
  that explains the motivation (the "why"), not a mechanical list of
  edits. See `git log --oneline` for the pattern.
- Test-first development — when asked for a new feature, add an
  expect-test in `compiler/tests-compiler/end_to_end.ml` that
  exercises it, watch it fail, then implement. Most features listed
  above landed this way.
- Don't reach for the opam compiler-libs internals beyond
  `Symtable.global_map` unless asked — `Obj` traversal of marshalled
  compiler types is fragile across OCaml versions and the user has
  explicitly steered us away from it.

## Future alignment with js_of_ocaml

Structural and API-level alignments with `js_of_ocaml`/`wasm_of_ocaml`
that have been identified but deferred (typically because they depend on
introducing an intermediate representation, or only pay off once the
feature set demands it) are tracked in [`docs/ALIGNMENT.md`](docs/ALIGNMENT.md).
Add newly spotted items there rather than letting them slip.
