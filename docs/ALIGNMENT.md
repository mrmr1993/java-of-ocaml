# Alignment with js_of_ocaml

`java_of_ocaml` is modeled on `js_of_ocaml` / `wasm_of_ocaml`. This
document tracks structural / API-level gaps between the two projects
as a roadmap. Resolved items are removed once landed — git history
retains the details.

Add new items as they are spotted.

## IR-dependent alignments

- **`Parse_bytecode.from_cmo` / `from_cma`** —
  `js_of_ocaml/compiler/lib/parse_bytecode.mli`. In progress:
  `Bytecode.read_cmo` / `read_cma` / `read_file` read the format;
  `Linker.link` merges one or more `unit_info`s into a
  `Bytecode.t` equivalent (predefined exception descriptors at
  canonical slots, per-compunit globals, interned literals, merged
  primitive table, patched code words). Still to do: wire
  `Linker.link` into the `Compile` driver so a `.cmo` input works
  end-to-end (including propagating the main/init entry point),
  add a `link` CLI sub-command that accepts multiple inputs, and
  ship a precompiled Stdlib/Core archive so unknown-compunit
  placeholder slots actually get filled in at load time. Once
  done, we can compile libraries without linking them into a
  bytecode executable first.
- **`Flow.Info.t` / `Flow.f`** —
  `js_of_ocaml/compiler/lib/flow.ml`. Flow-sensitive constant
  propagation and shape facts. Would extend `Jvm_typing`'s forward
  pass with def-use propagation and a more precise Var.t → Kind.kind
  lattice.
- **Optimization passes** — `Inline`, `Tailcall`, `Global_deadcode`
  in `js_of_ocaml/compiler/lib/`. All backend-agnostic; operate on
  `Code.program → Code.program`.
  - `Deadcode` still lacks jsoo's dead-param elimination (dropping
    block params no terminator arg actually feeds) — a natural
    follow-up now that `Pure_fun` is in place.
  - `Pure_fun` only sees the current function's blocks (each
    function is parsed as its own `Code.program`), so it can't
    classify a closure whose body lives in a sibling program. A
    cross-function purity pass would need whole-program IR first.
  - `Eval` is block-local; jsoo's eval consults `Flow.Info.t` to
    propagate constants across block edges. A `Flow` port is the
    gating item for stronger eval, inlining, and `Shape`
    inference.
- **`Closure_conversion`** —
  `js_of_ocaml/compiler/lib-wasm/closure_conversion.ml`. Our IR
  already carries explicit `captures` in `Closure`, but a separate
  conversion pass would give us free-variable analysis and match
  jsoo's layering.
- **`Curry`** — `js_of_ocaml/compiler/lib-wasm/curry.ml`. Generates
  arity-specific apply/curry helpers; semantically close to our
  hand-rolled `PartialClosure` + `apply1..apply7` dispatch in
  `runtime-java/`.
- **`Shape` inference** — `js_of_ocaml/compiler/lib/shape.ml`.
  Finer-grained than our `Kind.kind`.

## Tooling & feature gaps

- **Missing sub-commands on the CLI** —
  `js_of_ocaml/compiler/bin-js_of_ocaml/` defines `link`,
  `build-fs`, `build-runtime`, `print-runtime`, `check-runtime`.
  The Cmdliner scaffolding is in place (`compile` is the default,
  `print-runtime` exists) but the rest don't yet have analogues.
  `link` is the important one once `from_cmo` / `from_cma` lands;
  `check-runtime` needs a runtime-primitive registry to validate
  against, which we also don't have.
- **Source maps: per-expression granularity + JSR-45 SMAP** —
  `js_of_ocaml/compiler/lib/source_map.ml`,
  `lib-wasm/wasm_source_map.ml`. We emit JVM `SourceFile` +
  `LineNumberTable` from the DBUG section, but only at IR block
  entries, so straight-line code inside one block reports the
  block's starting line. Finer-grained mapping would need
  per-instruction bytecode PCs threaded through `Code.instr`.
  Stepped debugging in JVM tooling would additionally need a
  `SourceDebugExtension` (SMAP / JSR-45) attribute — different
  mapping target from jsoo's but the design is a useful
  reference.
- **Target-backend signature** —
  `js_of_ocaml/compiler/lib-wasm/target_sig.ml`. Only pays off
  once we have more than one backend (Dalvik, CIL, …), but even
  with one it documents the runtime-value contract.
- **Effects / CPS translation** —
  `js_of_ocaml/compiler/lib/effects.ml`. Needed if we ever support
  OCaml 5 effect handlers.
- **Stdlib IR cache (optimisation, not a correctness item).**
  Jsoo re-lowers Stdlib from bytecode on every invocation and it's
  fast enough in practice; we do the same. If compile times ever
  become painful, the cheapest speedup is caching the output of
  `Parse_bytecode.from_cma` on `$(ocamlc -where)/stdlib.cma`
  (IR-level cache) and re-running codegen each compile. Full
  ahead-of-time class-file precompilation was considered and
  dropped — correct but adds bootstrap staging and slot-assignment
  plumbing for a win that's uncertain.
- **`StackMapTable` / Java 6+ verifier** — we emit Java 5
  class-file format (major version 49), relying on the old
  type-inference verifier. Moving to the stricter Java 6+ verifier
  would need `StackMapTable` attributes but would make our output
  compatible with tools that reject the older format.

## Known representation gaps

- **Integer width** — our ints run as JVM 32-bit `int`, not OCaml's
  63-bit tagged int. Arithmetic, shifts, and bitwise ops silently
  wrap at the JVM boundary. A 63-bit-clean representation would
  either promote every int to `long` or keep `int` everywhere and
  add explicit wrap-to-63-bit masks on operations; jsoo takes the
  first approach for `nativeint` / `int64` but leaves plain `int`
  as a JS number. We should pick a strategy before `int64`
  arithmetic or `Sys.int_size`-dependent code (popcount,
  leading_zeros) starts mattering.
- **JVM method bodies past 64 KB** — even with branch relaxation
  in place (`Jvm_code.resolve` widens overflowing short branches
  to `goto_w` / trampolines), a single method's `Code` attribute
  is capped at 65 535 bytes by the class-file format. We haven't
  hit this yet, but deep Stdlib internals will eventually. The
  jsoo escape hatch here is splitting: spill long runs of straight
  -line code into auxiliary methods that the main body calls.

## Stdlib wrapper functions needing `Invalid_argument`

Several Stdlib functions (`Array.sub`, `Array.blit`, `Array.fill`,
`String.sub`, `Bytes.sub`, `Buffer.*`) are thin OCaml wrappers
around an `external` primitive that calls `Stdlib.invalid_arg` for
bounds-check failures. The primitive itself works; the wrapper
doesn't, because `Stdlib.invalid_arg` is a closure living in the
`Stdlib` module record. Tests bind the underlying `external`
directly to sidestep this. Resolved once the full `Stdlib` module
record materialises.

## Feature gaps

Listed here because each has an analogue in jsoo worth studying
when implementing:

- Non-inlined `Obj` entry points that flow through a closure
  reference (e.g. `Obj.is_block`, `Obj.Extension_constructor.*`).
  Require pulling in the `Obj` module record from
  `caml_global_data`, which we can't materialise yet because its
  fields are closures. The inlined externals (`%obj_is_int`,
  `%obj_size`, `%obj_field`, `%obj_set_field`, `%identity`) work,
  as do the C primitives `caml_obj_tag`, `caml_obj_block`,
  `caml_obj_with_tag`, `caml_obj_dup`.
- `Lazy.t` / `lazy` / `Lazy.force`.
- `module rec` — simple cases pass (`corecursion.ml` tests);
  deeper `CamlinternalMod`-driven patterns still hit runtime
  failures. jsoo uses `CamlinternalMod`'s lazy-initialised
  placeholders end-to-end.
- `Printf.printf` via `CamlinternalFormat` — hits an `ENVACC
  capture N out of range` during emission. Closure-analysis
  mismatch when a nested ENVACC chain sees the wrong `ncaps`.
- I/O beyond stdout, threads.
