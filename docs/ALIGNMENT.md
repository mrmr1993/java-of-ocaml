# Alignment with js_of_ocaml

`java_of_ocaml` is modeled on `js_of_ocaml` / `wasm_of_ocaml`. This
document tracks structural or API-level alignments with those
projects — resolved ones (what's in place today) as a pointer for
where to look when debugging, and deferred ones as a roadmap.

Add new items as they are spotted. Delete resolved items' history
with a PR-sized description — git history retains the details.

## Resolved: structural IR

- **`Code.program` IR** —
  `compiler/lib-java/code.ml{,i}`, adapted from
  `js_of_ocaml/compiler/lib/code.ml`. Drops CPS, Event, Special;
  keeps `Var` / `Addr` / `constant` / `expr` / `instr` / `last` /
  `block` / `program` plus `Print` pretty-printers and
  `fold_children`. `Switch` carries separate `int_cases` +
  `tag_cases` arrays to match OCaml's mixed-dispatch SWITCH
  semantics.
- **`Parse_bytecode`** —
  `compiler/lib-java/parse_bytecode.ml{,i}`. Block-boundary scan
  via `Instr.branch_targets` + terminator successors; a parser
  state threading accu + OCaml-stack slots + env; DFS over blocks
  with dynamic target-params promotion; full coverage of the
  opcode subset `java_of_ocaml` uses.
- **`Jvm_typing`** (per-Var forward kind inference) +
  **`Jvm_generate`** (IR → JVM bytecode) —
  `compiler/lib-java/jvm_typing.ml{,i}` +
  `compiler/lib-java/jvm_generate.ml{,i}`. Generate walks blocks
  in topological order, maintains `Var.t → JVM local`, coerces at
  block-edge parallel renames (convert-on-assign idiom from jsoo's
  `lib-wasm/generate.ml:1920`), and emits bytecode via
  `Jvm.Code`.

## Deferred: IR-dependent alignments

The IR is in place; these would be natural layered additions now.

- **`Parse_bytecode.from_cmo` / `from_cma`** —
  `js_of_ocaml/compiler/lib/parse_bytecode.mli`. We currently only
  read CODE / PRIM / DATA from a full executable. Separate-
  compilation inputs (`.cmo` / `.cma`) would let us compile
  libraries without linking them into a bytecode executable first.
- **`Flow.Info.t` / `Flow.f`** —
  `js_of_ocaml/compiler/lib/flow.ml`. Flow-sensitive constant
  propagation and shape facts. Would extend `Jvm_typing`'s forward
  pass with def-use propagation and a more precise Var.t → Kind.kind
  lattice.
- **Optimization passes** — `Deadcode`, `Inline`, `Eval`,
  `Tailcall`, `Global_deadcode` in `js_of_ocaml/compiler/lib/`.
  All backend-agnostic; operate on `Code.program → Code.program`.
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

## Deferred: tooling & feature gaps

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
- **Stdlib compilation pipeline** — jsoo compiles all of Stdlib
  ahead-of-time and links it in. We currently compile Stdlib from
  the input bytecode on the fly, which means each program's
  Stdlib chunks are re-compiled. A precompiled-Stdlib cache would
  be a significant speedup, and would let us sidestep the handful
  of Stdlib internals we don't yet get through.
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
- **Large method bodies** — the JVM branch-offset format is signed
  16-bit, so a method body more than ~32 KB of bytecode breaks
  class-file assembly. Deep Stdlib internals (`Marshal`, deep
  `Printf` routing) can exceed this. Fixes: use `goto_w` / `jsr_w`
  for branches beyond the 16-bit window, or split long methods
  into pieces.

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
