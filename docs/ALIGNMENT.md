# Alignment with js_of_ocaml

`java_of_ocaml` is modeled on `js_of_ocaml`/`wasm_of_ocaml`. This document
tracks structural or API-level alignments that have been *identified* but
deferred — typically because they depend on infrastructure we don't yet
have (notably an intermediate representation), or because the cost is
only justified once the feature set demands it.

Add new items as they are spotted. Delete resolved items — git history
retains them.

## Deferred: IR-dependent alignments

These all depend on introducing an intermediate representation (either
a home-grown one or, preferably, adopting `Code.program` from
`js_of_ocaml-compiler`).

- **`Code.program` IR** —
  `js_of_ocaml/compiler/lib/code.ml(i)`. Blocks, variables,
  instructions, last-terminators, continuations. The single biggest
  structural divergence from jsoo: our compile pipeline walks the
  OCaml bytecode stream directly instead of lowering it to an IR
  first.
- **`Parse_bytecode.from_exe`** —
  `js_of_ocaml/compiler/lib/parse_bytecode.mli`. Reads
  CODE/PRIM/DATA/SYMB and produces `Code.program` directly. A drop-in
  for `compiler/lib-java/bytecode.ml` once the IR lands, together
  with `from_cmo` / `from_cma` for separate-compilation inputs.
- **`Flow.Info.t` / `Flow.f`** —
  `js_of_ocaml/compiler/lib/flow.ml`. Flow-sensitive
  constant-propagation and shape facts. A principled successor to our
  ad-hoc `Inference.infer_return_kind` / `infer_arg_kinds`.
- **Optimization passes** — `Deadcode`, `Inline`, `Eval`, `Tailcall`,
  `Global_deadcode` in `js_of_ocaml/compiler/lib/`. All
  backend-agnostic; operate on `Code.program → Code.program`.
- **`Closure_conversion`** —
  `js_of_ocaml/compiler/lib-wasm/closure_conversion.ml`. Flattens
  closures to explicit free-variable records; would feed our
  per-function `Closure` subclass generator.
- **`Curry`** — `js_of_ocaml/compiler/lib-wasm/curry.ml`. Generates
  arity-specific apply/curry helpers; semantically close to the
  hand-rolled `PartialClosure` + `apply1..apply7` dispatch in
  `runtime-java/`.
- **`Shape` inference** — `js_of_ocaml/compiler/lib/shape.ml`.
  Finer-grained than `Kind`.

## Deferred: features beyond current maturity

- **Proper CLI via Cmdliner** —
  `js_of_ocaml/compiler/bin-js_of_ocaml/` and `bin-wasm_of_ocaml/`
  define sub-commands (`compile`, `link`, `check-runtime`, …). The
  single `java_of_ocaml.exe` entry point will need breaking up once
  linking / runtime checks / other commands exist.
- **Separate compilation (`.cmo` / `.cma`)** — we only consume linked
  `.exe` bytecode; `Parse_bytecode.from_cmo` / `from_cma` cover the
  other entry points.
- **Source maps** — `js_of_ocaml/compiler/lib/source_map.ml`,
  `lib-wasm/wasm_source_map.ml`. Stepped debugging in JVM tooling
  would need a different mapping target (e.g. SMAP for JSR-45), but
  the design is a useful reference.
- **Target-backend signature** —
  `js_of_ocaml/compiler/lib-wasm/target_sig.ml`. Only pays off once
  we have more than one backend (Dalvik, CIL, …), but even with one
  it documents the runtime-value contract.
- **Effects / CPS translation** —
  `js_of_ocaml/compiler/lib/effects.ml`. Needed if we ever support
  OCaml 5 effect handlers.
- **Stdlib compilation pipeline** — jsoo compiles all of Stdlib
  ahead-of-time and links it in. Currently `java_of_ocaml` falls back
  to a handful of custom C primitives (`caml_java_print_*`, array
  ops). Replacing that requires either our own Stdlib compilation or
  cross-compiled artefacts.

## Known representation gaps

- **Integer width** — our ints run as JVM 32-bit `int`, not OCaml's
  63-bit tagged int. Arithmetic, shifts, and bitwise ops silently
  wrap at the JVM boundary. A 64-bit-clean representation would
  either promote every int to `long` or keep `int` everywhere and
  add explicit wrap-to-63-bit masks on operations; jsoo takes the
  first approach for `nativeint`/`int64` but leaves plain `int` as
  a JS number. We should pick a strategy before either int64
  arithmetic or Sys.int_size-dependent code (popcount,
  leading_zeros) starts mattering.

## Known bugs surfaced but not fixed

Recorded here so they don't get lost; each has a focused repro.

- **Oversupply + inline closure call**:

  ```ocaml
  let mk n = fun x -> x + n
  let () = caml_java_print_int (mk 10 32)
  ```

  Direct CLI invocation of `java_of_ocaml.exe` on the resulting
  bytecode produces a correct `Main.class` that prints `42`; running
  through `compile_and_run` / `compile_and_javap` inside dune's test
  sandbox fails with `kind mismatch — have Locaml_fn_0;, need I`.
  Exact environmental divergence is unclear — same binary hash, same
  source bytes, same cwd-to-bytecode flow — but the test sandbox
  reliably triggers it. Binding the intermediate (`let add10 = mk 10
  in add10 32`) avoids it entirely. Run with
  `JAVA_OF_OCAML_DEBUG=emit` for a per-opcode trace of acc-kind
  transitions.

## Feature gaps (also noted in the README / CLAUDE.md)

Listed here because each has an analogue in jsoo worth studying when
implementing:

- Non-inlined `Obj` entry points that flow through a closure
  reference (e.g. `Obj.is_block`, `Obj.Extension_constructor.*`).
  Those require pulling in the `Obj` module record from
  `caml_global_data`, which we can't materialise yet because its
  fields are closures; the inlined externals (`%obj_is_int`,
  `%obj_size`, `%obj_field`, `%obj_set_field`, `%identity`) work, as
  do the C primitives `caml_obj_tag`, `caml_obj_block`,
  `caml_obj_with_tag`, `caml_obj_dup`.
- `Lazy.t` / `lazy` / `Lazy.force`.
- `module rec` (jsoo uses `CamlinternalMod`'s lazy-initialised
  placeholders).
- Floats, IO, threads.
