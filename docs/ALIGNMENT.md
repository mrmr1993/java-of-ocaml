# Alignment with js_of_ocaml

`java_of_ocaml` is modeled on `js_of_ocaml`/`wasm_of_ocaml`. This document
tracks structural or API-level alignments that have been *identified* but
deferred to a later phase — typically because they depend on infrastructure
we don't yet have (notably an intermediate representation), or because the
cost is only justified once the feature set demands it.

New items are added as they are spotted. Resolved items are deleted (the
git history retains them).

## Deferred: IR-dependent alignments

These all depend on introducing an intermediate representation (either a
home-grown one or, preferably, adopting `Code.program` from
`js_of_ocaml-compiler`). See the alignment plan at
`~/.claude/plans/we-need-to-create-glistening-turing.md` for the rationale.

- **`Code.program` IR** — `js_of_ocaml/compiler/lib/code.ml(i)`. Blocks,
  variables, instructions, last-terminators, continuations. The single
  biggest structural divergence from jsoo. Replaces our monolithic
  `compile.ml` direct bytecode→JVM walk.
- **`Parse_bytecode.from_exe`** — `js_of_ocaml/compiler/lib/parse_bytecode.mli`.
  Reads CODE/PRIM/DATA/SYMB and produces `Code.program` directly. Would
  replace our custom `bytecode.ml` (408 LoC). Tied to IR adoption.
- **`Flow.Info.t` / `Flow.f`** — `js_of_ocaml/compiler/lib/flow.ml`.
  Flow-sensitive constant-propagation and shape facts. A principled
  successor to our ad-hoc `infer_return_kind` / `infer_arg_kinds` passes.
- **Optimization passes** — `Deadcode`, `Inline`, `Eval`, `Tailcall`,
  `Global_deadcode` in `js_of_ocaml/compiler/lib/`. All backend-agnostic;
  operate on `Code.program → Code.program`.
- **`Closure_conversion`** — `js_of_ocaml/compiler/lib-wasm/closure_conversion.ml`
  (168 LoC). Flattens closures to explicit free-variable records. Would let
  us generate one `Closure` subclass per function from a clean input.
- **`Curry`** — `js_of_ocaml/compiler/lib-wasm/curry.ml` (385 LoC). Generates
  arity-specific apply/curry helpers; semantically close to our hand-rolled
  `PartialClosure` + `apply1..apply7` dispatch.
- **`Shape` inference** — `js_of_ocaml/compiler/lib/shape.ml`. Finer-grained
  than kinds.

## Deferred: features beyond current maturity

- **Proper CLI via Cmdliner** — `js_of_ocaml/compiler/bin-js_of_ocaml/` and
  `bin-wasm_of_ocaml/` define sub-commands (`compile`, `link`,
  `check-runtime`, ...). Our single `java_of_ocaml.exe` is fine for now
  but will need breaking up when we add linking / runtime checks / etc.
- **Separate compilation (`.cmo`/`.cma`)** — we only consume linked `.exe`
  bytecode. `Parse_bytecode.from_cmo` / `from_cma` cover the other entry
  points.
- **Source maps** — `js_of_ocaml/compiler/lib/source_map.ml`,
  `lib-wasm/wasm_source_map.ml`. Stepped debugging in JVM tooling would need
  a different mapping target (e.g. SMAP for JSR-45), but the design is a
  useful reference.
- **Target-backend signature** — `js_of_ocaml/compiler/lib-wasm/target_sig.ml`.
  Only pays off once we have more than one backend (Dalvik, CIL, ...), but
  even with one it documents the runtime-value contract.
- **Effects / CPS translation** — `js_of_ocaml/compiler/lib/effects.ml`.
  Needed if we ever support OCaml 5 effect handlers.
- **Stdlib compilation pipeline** — jsoo compiles all of Stdlib
  ahead-of-time and links it in. We currently fall back to custom C
  primitives (`caml_java_print_*`). Replacing that requires either our own
  Stdlib compilation or cross-compiled artefacts.

## Feature gaps (tracked elsewhere too)

These are features noted in `README.md` / `CLAUDE.md` as unsupported;
listed here only because each has an analogue in jsoo that we'll want to
study when implementing:

- `Obj` module support.
- `Lazy.t` / `lazy` / `Lazy.force` (depends on `Obj`).
- `module rec` (jsoo uses `CamlinternalMod`'s lazy-initialised
  placeholders).
- Floats, IO, threads.

## Remaining structural work (not IR-dependent)

Items from the original alignment plan that are still open but don't
need an IR:

- **Further `compile.ml` split** — the mutable `state` record and its
  helpers are now in `State`, but the ~1700 LoC of `emit_*` functions
  plus the `compile` driver still share one file. They're
  mutually-recursive through `state` + label resolution, so the split
  wants a thought-out decomposition (probably one `.ml` per opcode
  family, with emit_instr left as the dispatch surface). Parallel to
  how `js_of_ocaml/compiler/lib/generate.ml` is still ~2500 LoC in
  jsoo, this is not an easy cleanup.
- **Per-pass Debug printers** — `Debug` is wired and three flags are
  live (`times`, `primitives`, `functions`). Missing: a flag that
  dumps `state.slots` / `state.acc_kind` at each emitted opcode,
  which would help triage verify-errors. Roughly equivalent to jsoo's
  `Code.Print.program`.
- **Broader emission snapshot coverage** — `emission_snapshots.ml`
  pins two representative programs. One snapshot per emit category
  (variants, closures, try/with, ...) would close the gap.

## Alignments already adopted

For completeness, notes on jsoo pieces we have already leaned on, and
structural alignments already made in-tree:

- **`Symtable.global_map`** — via `compiler-libs.bytecomp`. Used in
  `compiler/lib-java/bytecode.ml` for SYMB parsing. (Not from jsoo
  itself, but the same public API jsoo uses.)
- **Module granularity** — jsoo's "one concern per file" discipline.
  `jvm.ml` was split into `jvm_bin` / `jvm_constant_pool` / `jvm_code`
  / `jvm_class_file` / `jvm_runtime`. `compile.ml` had seven concerns
  extracted (`global_view`, `instr`, `kind`, `function_info`, `prim`,
  `inference`, `state`); the old 2972-LoC monolith is now ~2080 LoC of
  emit_* + driver, plus those seven siblings.
- **`.mli` discipline** — every newly-extracted module has a
  comprehensive `.mli`. `compile.mli` is still a minimal 4-line
  export; upgrading it is coupled to the emit_* split above.
- **`Debug` / `Timer` modules** — modeled directly on
  `js_of_ocaml/compiler/lib/debug.ml` + `timer.ml`. Opt-in via
  `JAVA_OF_OCAML_DEBUG=…`.
- **Per-topic test files** — jsoo's `tests-compiler/` layout. The old
  single 1474-LoC `end_to_end.ml` is now 15 topic files
  (`modules.ml`, `variants.ml`, `exceptions.ml`, …) auto-discovered
  by `gen-rules/gen.exe`.
- **Snapshot testing at the emission layer** —
  `Util.compile_and_javap` runs `javap -c Main.class` and pins the
  disassembly, mirroring jsoo's `tests-compiler/*.ml` snapshot style.
- **Hand-authored runtime** — Block / Closure / PartialClosure /
  CamlException are now Java source under `runtime-java/`, compiled
  with `javac`, embedded into an OCaml string literal at build time.
  Replaces ~400 LoC of OCaml byte-emission. Mirrors jsoo's
  `runtime/wasm/*.wat` + `runtime/js/*.js` split.
