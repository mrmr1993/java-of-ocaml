# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**java-of-ocaml** compiles OCaml bytecode executables (as produced by
`ocamlc`) to JVM class files. It is modeled after `wasm_of_ocaml` (the
WASM backend in `js_of_ocaml`), which compiles OCaml bytecode to
WebAssembly.

The project uses a local opam switch with OCaml 5.3.0 and dune 3.17.

### What's implemented

Every feature listed below is covered by at least one test under
`compiler/tests-compiler/`. `dune runtest` runs the whole suite.

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
  :=`, `module type of`, first-class modules.
- **Recursive values** — `let rec a = A (b, b) and b = [|a; a; a|]`
  via `caml_alloc_dummy` / `caml_update_dummy`.
- **`Obj`** — the inlined externals (`%identity` via `Obj.repr` /
  `Obj.obj` / `Obj.magic`, `%obj_is_int`, `%obj_size`, `%obj_field`
  via `Parrayrefu gen_array_kind` → `caml_array_unsafe_get`,
  `%obj_set_field` → `caml_array_unsafe_set`) and the C primitives
  `caml_obj_tag`, `caml_obj_block`, `caml_obj_with_tag`,
  `caml_obj_dup`. Non-inlined entry points like `Obj.is_block` still
  need the `Obj` module record, which depends on Stdlib compilation.
- **`Int`** (arithmetic / bitwise / shifts) — `neg`, `succ`, `pred`,
  `add`/`sub`/`mul`/`div`/`rem`, `logand`/`logor`/`logxor`,
  `shift_left`/`shift_right`/`shift_right_logical`, and the infix
  `land`/`lor`/`lxor`/`lsl`/`lsr`/`asr`. Shifts are JVM-int (32-bit),
  not OCaml's 63-bit, so programs that depend on the width beyond 31
  bits will diverge — a separate item.
- **`Float`** — `+.` / `-.` / `*.` / `/.`, unary `-.`, `Float.abs`,
  NaN-safe float comparisons (via `dcmpl` / `dcmpg` chosen per
  operator), `int_of_float` / `float_of_int`. Floats flow as JVM
  `double`; boxed to `java.lang.Double` when passed to `Object`-typed
  apply slots and unboxed via `doubleValue` at point of use. Float
  locals and stack slots are 2-wide — `Kind.local_slots_for_kind` and
  `State.allocate_local_for_kind` reserve the second slot.
- **`Array`** — `Array.make`, `Array.length`, safe and unsafe
  indexed get/set, and the `caml_array_sub` / `caml_array_blit` /
  `caml_array_fill` / `caml_array_append` externals. Arrays are the
  existing `Block` representation, so `Array` piggybacks on
  everything we built for `Obj.{field,set_field,size}`. The
  user-facing `Array.sub` / `Array.blit` / `Array.fill` wrappers in
  Stdlib call `Stdlib.invalid_arg` for bounds violations, which
  we can't materialise yet — tests bind the underlying externals
  directly.

Not yet supported:

- No general `Stdlib` — e.g. `print_endline`, `^`, `@`, `List.iter`
  would still fall back to Stdlib's compiled bytecode, which isn't
  compiled. Tests use custom C primitives (`caml_java_print_int`,
  `caml_java_print_endline`, `caml_java_print_float`) for output.
  `Stdlib.nan` and similar constants live in the Stdlib module
  record and can't be materialised yet.
- `module rec` — OCaml lowers these via `CamlinternalMod`'s
  lazy-initialised placeholders.
- `Lazy.t` / `lazy` / `Lazy.force`.
- IO, threads, effects.

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
dune runtest compiler/tests-compiler       # The main ppx_expect suite
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

Each module under `compiler/lib-java/` has a companion `.mli`.

- `compiler/lib-java/` — the compiler library
  (`java_of_ocaml_compiler`).

  Input & low-level emission:
    - `bytecode` — bytecode-executable reader. Decodes CODE, PRIM,
      DATA, SYMB. SYMB parsing goes through `compiler-libs.bytecomp`'s
      `Symtable.global_map` (do NOT re-implement via `Obj` traversal —
      that route is fragile across OCaml versions and has been
      explicitly ruled out).
    - `jvm_bin` / `jvm_constant_pool` / `jvm_code` / `jvm_class_file` —
      class-file construction. `jvm_bin` is the u1/u2/u4 buffer
      helpers; `jvm_constant_pool` is the `Cp` builder; `jvm_code` is
      the method-body builder (labels, exception entries, straight-
      line push/pop accounting); `jvm_class_file` assembles a class
      from methods + fields + cp.
    - `jvm_runtime` — re-exports the runtime-class byte blobs compiled
      from the Java sources under `runtime-java/`.

  Analysis passes (pure on bytecode, populate metadata):
    - `global_view` — Gv_* / G_* classification of `Obj.t` entries in
      the DATA section (integers, strings, nested blocks).
    - `instr` — decoded `instr = { pc; opcode; args }`, opcode
      classification (`is_c_call`, `is_user_op`, …), branch-target
      arithmetic.
    - `kind` — `kind = K_int | K_string | K_block of kind list |
      K_closure of closure_ref | K_obj` plus JVM descriptor / box /
      unbox / load / store helpers.
    - `function_info` — per-OCaml-function metadata (class name, pc
      range, nargs, ncaps, inferred kinds, CLOSUREREC group pointer).
    - `prim` — the registry of supported C primitives (`prim_handler`,
      `prim_entry`, `find_supported_prims`).
    - `inference` — pre-passes that walk the decoded bytecode once
      each: user-range detection (`supported_call_indices`,
      `walk_back_user_start`, `walk_forward_user_end`), return-kind /
      arg-kind inference.
    - `state` — mutable emitter state: OCaml-stack slots, acc
      live/kind, JVM local allocator, pc→label map, branch-target
      snapshots, pending cmp, pending retaddrs, open traps, etc.
      Also hosts the `ensure_kind` / `box_acc_to_object` /
      `overwrite_acc` / `allocate_local` / slot helpers every emitter
      uses.

  Emission (per-topic opcode handlers, all take `state`):
    - `emit_stack` — PUSH, ACC{0..7,N}, PUSHACC{0..7,N}, CONST*,
      PUSHCONST*, plus the block-constant materialiser used by
      GETGLOBAL. The core push / acc primitives every other emitter
      composes with.
    - `emit_arith` — NEGINT, ADDINT, SUBINT, MULINT, DIVINT, MODINT,
      ANDINT, ORINT, XORINT, LSLINT, LSRINT, ASRINT, OFFSETINT.
    - `emit_branch` — cmp_of_opcode, BEQ/BNEQ/BLTINT/BLEINT/BGTINT/
      BGEINT, BRANCHIF/NOT-on-K_obj, SWITCH, fused compare-and-branch,
      `flush_pending_cmp` for the comparison-followed-by-non-branch
      case (e.g. a boolean expression evaluated as an expression
      tail).
    - `emit_apply` — APPLY / APPLY1..3 / APPTERM / RETURN /
      PUSH_RETADDR, plus the `apply_descriptor_for_nargs` helper.
    - `emit_closure` — CLOSURE / CLOSUREREC, OFFSETCLOSURE{0,3,m3,N},
      ENVACC, PUSHENVACC, and the shared closure-allocation /
      sibling-resolution helpers.
    - `emit_exception` — RAISE / PUSHTRAP / POPTRAP.
    - `emit_primitive` — the C_CALL handlers
      (`caml_java_print_{int,endline,float}`,
      `caml_array_{get,set}_addr`, `caml_array_{get,set}`,
      `caml_array_unsafe_{get,set}`, `caml_array_make` /
      `caml_make_vect`, `caml_array_sub`, `caml_array_blit`,
      `caml_array_fill`, `caml_array_append`, `caml_obj_dup`,
      `caml_obj_tag`, `caml_obj_block`, `caml_obj_with_tag`,
      `caml_fresh_oo_id`, `caml_alloc_dummy`, `caml_update_dummy`,
      float arithmetic `caml_{add,sub,mul,div}_float`,
      `caml_{neg,abs}_float`, the six `caml_{eq,neq,lt,le,gt,ge}_float`
      comparisons, `caml_int_of_float` / `caml_float_of_int`,
      `caml_int_of_string` / `caml_format_int`) plus ISINT. Shared
      helpers for dynamic block-field read/write back `GETVECTITEM`
      and `SETVECTITEM` in `emit_instr`.
    - `emit_instr` — the opcode dispatcher. Handles label marking
      (with CamlException-unwrap prelude at try/with handler entry)
      and branch-target state restoration, then dispatches to the
      emit_* modules above. A handful of small opcodes are emitted
      inline (MAKEBLOCK, GETFIELD, SETFIELD, VECTLENGTH,
      GETVECTITEM, SETVECTITEM, OFFSETREF, BRANCH, BRANCH(IF/NOT),
      ASSIGN, BOOLNOT, POP, GETGLOBAL, PUSHGETGLOBAL,
      GETGLOBALFIELD, PUSHGETGLOBALFIELD).

  Driver:
    - `compile.{ml,mli}` — the compile driver. Reads the bytecode,
      locates the user range via seed primitives (`caml_java_print_*`,
      array ops — NOT `caml_fresh_oo_id`, which also appears in Stdlib
      init), runs the CLOSUREREC pre-scan, runs `Inference` to
      populate function_info kinds, builds the initial State, calls
      `Emit_instr.emit_instr` over each bytecode instruction, then
      generates one class file per OCaml function plus `Main.class`.
      Wires Debug/Timer for opt-in tracing.

  Instrumentation:
    - `debug` / `timer` — opt-in per-pass tracing/timing. Toggle via
      `JAVA_OF_OCAML_DEBUG=times,primitives,functions,emit` (comma-
      separated; any subset).

- `compiler/bin-java_of_ocaml/` — the `java_of_ocaml.exe` CLI binary.
- `runtime-java/` — Java sources for the runtime classes
  (`Block.java`, `Closure.java`, `PartialClosure.java`,
  `CamlException.java`). `javac` compiles them, `embed_class_bytes.ml`
  reads the resulting `.class` files and emits `runtime_bytes.ml` as
  the `java_of_ocaml_runtime_bytes` library; `jvm_runtime` re-exports
  its four bindings. Editing the runtime means editing the Java
  sources — `javac` catches typos at build time.
- `compiler/tests-compiler/` — ppx_expect tests, one file per topic
  (`arithmetic.ml`, `functions.ml`, `variants.ml`, `modules.ml`,
  `exceptions.ml`, `lists.ml`, `corecursion.ml`, `high_arity.ml`,
  `gadts.ml`, `extensible.ml`, `records.ml`, `refs.ml`, `strings.ml`,
  `tuples_records_arrays.ml`, `bytecode_smoke.ml`). Auto-discovered
  by `gen-rules/gen.ml` which generates `dune.inc`. Run `dune
  promote` after adding a new test file. `emission_snapshots.ml` is
  a separate file for javap-based disassembly snapshots.
- `compiler/tests-compiler/util/` — test helpers. Key functions:
  `compile_and_run s` (ocamlc → java_of_ocaml → java, prints stdout)
  and `compile_and_javap s` (same pipeline, then `javap -c
  Main.class`).
- `compiler/tests-java_of_ocaml/` — standalone executable tests with
  `.expected` output files. `byte` mode only; a `java` mode is
  aspirational pending a real dune plugin.
- `compiler/tests-full/` — library compilation tests. Currently
  mostly placeholder.
- `docs/ALIGNMENT.md` — index of deferred structural/API alignments
  with jsoo. Add new items there rather than letting them slip.

## Kind-tracking model

The `Kind` module's `kind` enum records what each OCaml-stack slot or
the accumulator holds at compile time, and determines where JVM `int`
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
`K_obj` (there is no whole-program arg-kind inference) and get cast /
unboxed via `State.ensure_kind state target` at each use. Return kinds
are inferred by `Inference.infer_return_kind`: `K_int` only for known
int-producing ops (`CONST*`, arithmetic, comparisons, …); `K_obj` for
everything else (including `ACC` / `ENVACC` / `APPLY`).

When a feature is failing with "APPLY called on a non-closure value"
or "GETFIELD on non-block" — the likely cause is `ensure_kind` not
being called on some new code path. Each pattern-matching branch,
each opcode that reads acc, has to decide whether acc's current kind
matches what it wants and unbox if not.

## Stacks to be aware of

1. **OCaml bytecode stack** — modeled by `state.slots`,
   `state.oc_stack_depth`. Each slot records a kind + the JVM local
   holding the pushed value.
2. **JVM operand stack** — tracked by `Jvm_code`'s internal
   `push`/`pop` accounting. Straight-line only — be careful with
   `dup` + `pop` on paths after a `goto`.
3. **JVM local-variable table** — `state.next_local` is monotonic
   (locals are never reused across push/pop; closures capture by JVM
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
  uses the old type-inference verifier; moving to the stricter
  verifier (Java 6+) would require emitting `StackMapTable`
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
  expect-test in the topic file under `compiler/tests-compiler/`
  that exercises it (`variants.ml`, `exceptions.ml`, etc., or a new
  topic file if none fits), watch it fail, then implement.
- Don't reach for the opam compiler-libs internals beyond
  `Symtable.global_map` unless asked — `Obj` traversal of marshalled
  compiler types is fragile across OCaml versions and has been
  explicitly ruled out.

## Future alignment with js_of_ocaml

Structural and API-level alignments with `js_of_ocaml`/`wasm_of_ocaml`
that have been identified but deferred (typically because they depend
on introducing an intermediate representation, or only pay off once
the feature set demands it) are tracked in
[`docs/ALIGNMENT.md`](docs/ALIGNMENT.md). Add newly spotted items
there rather than letting them slip.
