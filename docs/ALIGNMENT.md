# Alignment with js_of_ocaml

`java_of_ocaml` is modeled on `js_of_ocaml` / `wasm_of_ocaml`. This
document tracks structural / API-level gaps between the two projects
as a roadmap of **future work**. Resolved items are removed once
landed — git history retains the details. Descriptions of the
current implementation belong in `README.md` / `CLAUDE.md`, not here.

Add new items as they are spotted.

## IR-dependent alignments

- **Port `Flow.Info.t` / `Flow.f`** from
  `js_of_ocaml/compiler/lib/flow.ml`. Gating item for flow-sensitive
  constant propagation across block edges, stronger `Eval`, inlining,
  and a finer Var → Kind lattice.
- **Port `Shape` inference** —
  `js_of_ocaml/compiler/lib/shape.ml`. Finer-grained than our
  `Kind.kind`.
- **Port optimisation passes** from
  `js_of_ocaml/compiler/lib/`: `Inline`, `Tailcall`,
  `Global_deadcode`. Backend-agnostic `Code.program → Code.program`.
- **Dead-param elimination** in `Deadcode`: drop block params that
  no terminator arg actually feeds.
- **Cross-function purity** for `Pure_fun`. Needs whole-program IR
  (closures whose body lives in a sibling program currently can't
  be classified).
- **Port `Closure_conversion`** from
  `js_of_ocaml/compiler/lib-wasm/closure_conversion.ml`. A separate
  free-variable-analysis pass to match jsoo's layering.
- **Port `Curry`** from
  `js_of_ocaml/compiler/lib-wasm/curry.ml`. Arity-specific
  apply/curry helpers; replaces the hand-rolled `PartialClosure` +
  `apply1..apply7` dispatch.

## Tooling & feature gaps

- **CLI sub-commands** analogous to jsoo's: `build-fs`,
  `build-runtime`, `check-runtime`. `check-runtime` needs a
  runtime-primitive registry.
- **`SourceDebugExtension` (JSR-45 SMAP) attribute** so JVM stepped
  debugging shows OCaml file paths + lines on stack frames (design
  reference in jsoo's `source_map.ml`).
- **Target-backend signature** — port
  `js_of_ocaml/compiler/lib-wasm/target_sig.ml`. Pays off once
  there's a second backend (Dalvik, CIL, …), but documents the
  runtime-value contract even with one.
- **Effects / CPS translation** — port
  `js_of_ocaml/compiler/lib/effects.ml`. Needed for OCaml 5 effect
  handlers.
- **Stdlib IR cache** — if compile times become painful, cache the
  output of `Parse_bytecode.from_cma` on `stdlib.cma`. Lower-risk
  than full ahead-of-time class-file precompilation.
- **`StackMapTable` / Java 6+ verifier**. Our class files target
  Java 5 (major version 49) and rely on the old type-inference
  verifier. Emitting `StackMapTable` makes the output acceptable
  to tools that reject the older format.

## Known representation gaps

- **63-bit plain `int`**. JVM `int` is 32-bit; OCaml `int` is 63.
  Bitwise / overflow-sensitive code, `popcount`, `leading_zeros`,
  and anything that reads `Sys.int_size` will diverge. `Int64` /
  `Nativeint` are bit-accurate. Lifting plain `int` to `long` is
  invasive (Kind lattice, every load/store, every apply-method slot);
  no planned work.
- **Helper descriptors specialised by kind.** `Method_split.split`
  currently types every helper param as `Ljava/lang/Object;` and
  unbox/narrows on entry. When a helper's arg is known `K_int` /
  `K_float` at every call site, specialising the descriptor would
  skip the box/unbox round-trip.

## `Stdlib` module record

Several thin-wrapper Stdlib functions (`Array.sub`, `Array.blit`,
`Array.fill`, `String.sub`, `Bytes.sub`, `Buffer.*`) call
`Stdlib.invalid_arg` internally and fail because
`Stdlib.invalid_arg` is a closure living in the `Stdlib` module
record, which we can't fully materialise yet. Same blocker for
non-inlined `Obj` entry points that flow through a closure
reference (`Obj.is_block`, `Obj.Extension_constructor.*`). Resolved
once the full `Stdlib` / `Obj` module records materialise from
`caml_global_data`.

## Feature gaps

- **`module rec`** — deeper `CamlinternalMod`-driven patterns.
  jsoo uses `CamlinternalMod`'s lazy-initialised placeholders
  end-to-end.
- **`Printf.printf` via `CamlinternalFormat`** — hits an
  `ENVACC capture N out of range` during emission. Closure-analysis
  mismatch when a nested ENVACC chain sees the wrong `ncaps`.
