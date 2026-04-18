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
    Modelled after jsoo's per-concern module discipline; each of the
    following has a companion `.mli`:
    - `bytecode` — bytecode-executable reader. Decodes CODE, PRIM,
      DATA, SYMB. `SYMB` parsing goes through `compiler-libs.bytecomp`'s
      `Symtable.global_map` (do NOT re-implement via `Obj` traversal —
      user feedback asked specifically for compiler-libs here).
    - `jvm_bin` / `jvm_constant_pool` / `jvm_code` / `jvm_class_file` —
      low-level class-file construction. `jvm_bin` is the u1/u2/u4
      buffer helpers; `jvm_constant_pool` is the `Cp` builder;
      `jvm_code` is the method-body builder (labels, exception
      entries, straight-line [push]/[pop] accounting); `jvm_class_file`
      assembles a class from methods + fields + cp. `jvm.ml` is now a
      thin shim re-exporting `Cp` / `Code` + the runtime accessors so
      older callers see the same API.
    - `jvm_runtime` — re-exports the four runtime-class byte blobs
      produced by the Java sources under `runtime-java/`. See that
      directory for the real Java source.
    - `global_view` / `instr` / `kind` / `function_info` / `prim` /
      `inference` / `state` — the compile-time passes extracted out of
      the old monolithic `compile.ml`. `state` carries the mutable
      emitter state (OCaml stack, JVM locals, pending cmp, pending
      retaddrs, open traps, ...); `inference` runs the pre-passes that
      populate `function_info.{return_kind,arg_kinds}`.
    - `emit_stack` / `emit_arith` / `emit_branch` / `emit_apply` /
      `emit_closure` / `emit_exception` / `emit_primitive` — per-topic
      opcode emitters. Each takes `state` and emits into
      `state.code`. `emit_stack` holds the core push / acc / pushacc /
      constant primitives every other emitter composes with.
    - `emit_instr` — the opcode dispatcher. For each decoded
      [Instr.instr], it marks the JVM label at that PC (with a
      CamlException-unwrap prelude if it's a try/with handler entry),
      restores state from the branch snapshot, then dispatches to one
      of the emit_* modules above, with a handful of small opcodes
      emitted inline (MAKEBLOCK, GETFIELD, SETFIELD, VECTLENGTH,
      OFFSETREF, BRANCH, BRANCH(IF/NOT), ASSIGN, BOOLNOT, POP, GETGLOBAL,
      PUSHGETGLOBAL).
    - `compile.{ml,mli}` — the remaining compile driver. Locates the
      user range via seed primitives (`caml_java_print_*`, array ops
      — NOT `caml_fresh_oo_id`, which appears in Stdlib init), does the
      CLOSURE/CLOSUREREC pre-scan, runs kind inference, builds the
      initial state, calls `emit_instr` over each bytecode instruction
      in turn, then generates one class file per OCaml function +
      Main.class. Wires Debug/Timer for opt-in tracing. The `.mli` is
      minimal (one `compile : bc:string -> out_dir:string -> unit`).
    - `debug` / `timer` — opt-in per-pass tracing/timing. Enable via
      `JAVA_OF_OCAML_DEBUG=times,primitives,functions`.
- `compiler/bin-java_of_ocaml/` — the `java_of_ocaml.exe` CLI binary.
- `runtime-java/` — hand-written Java sources for the runtime
  classes (`Block.java`, `Closure.java`, `PartialClosure.java`,
  `CamlException.java`). Compiled with `javac` at build time;
  `embed_class_bytes.ml` reads the resulting `.class` files and
  emits `runtime_bytes.ml`, which is exposed as the
  `java_of_ocaml_runtime_bytes` library. `jvm_runtime` re-exports
  its four bindings. Editing the runtime means editing the Java
  sources; `javac` will catch typos at build time.
- `compiler/tests-compiler/` — ppx_expect tests, one file per topic
  (`arithmetic.ml`, `functions.ml`, `variants.ml`, `modules.ml`,
  `exceptions.ml`, ...). Auto-discovered by `gen-rules/gen.ml` which
  generates `dune.inc`. Run `dune promote` after adding new test
  files. `emission_snapshots.ml` is a separate file for javap-based
  disassembly snapshots.
- `compiler/tests-compiler/util/` — test helpers. Key functions:
  `compile_and_run s` (ocamlc → java_of_ocaml → java, prints stdout)
  and `compile_and_javap s` (same pipeline, then runs `javap -c
  Main.class` and prints the disassembly).
- `compiler/tests-java_of_ocaml/` — standalone executable tests with
  `.expected` output files. `byte` mode only; a `java` mode is
  aspirational pending a real dune plugin.
- `compiler/tests-full/` — library compilation tests. Currently
  mostly placeholder.
- `docs/ALIGNMENT.md` — running index of structural/API alignments
  with jsoo: done, open, deferred. Add notes there when a new
  alignment opportunity surfaces.

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
