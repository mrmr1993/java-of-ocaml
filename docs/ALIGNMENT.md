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

## Alignments already adopted

For completeness, notes on jsoo pieces we have already leaned on:

- **`Symtable.global_map`** — via `compiler-libs.bytecomp`. Used in
  `compiler/lib-java/bytecode.ml` for SYMB parsing. (Not from jsoo itself,
  but the same public API jsoo uses.)
