# Priority queue: compiling a large real-world OCaml codebase

This document sits alongside [`ALIGNMENT.md`](ALIGNMENT.md) and
reorders the outstanding work with one specific goal in mind:
compiling and testing a **large real-world OCaml application** —
the kind of codebase that pushes on every dimension of what a
backend has to support.

A caller profile we're optimising for is a ~1M-LOC production
OCaml project:

- Built on Jane Street's `Core` / `Base` / `Async` ecosystem, with
  heavy `ppx_jane`, `bin_prot`, and `ppx_inline_test`.
- Uses `Int64` / unsigned 64-bit arithmetic in hot paths, not just
  plain `int`.
- Ships a handful of C stubs (hashing, bignum, crypto primitives,
  filesystem helpers) that need JVM-side replacements or bridges.
- Built and tested via `dune`, with hundreds of separately-compiled
  libraries linked incrementally — not one monolithic executable.
- Relies on concurrency (monadic async / lightweight threads /
  scheduler) for roughly everything interesting.
- Inline tests drive correctness validation; a usable pipeline has
  to *run* those tests, not just compile them.

The generic "resolve alignment gaps with js_of_ocaml" ordering in
`ALIGNMENT.md` is written to produce a good compiler. The ordering
below is written to produce a compiler that can compile, link, and
run a codebase like the above. Optimisation quality drops in
priority; correctness-at-scale, build model, and runtime coverage
rise.

## Phase A — feasibility (can't attempt compilation otherwise)

1. **`from_cmo` / `from_cma` + `link` sub-command.** Linking the
   whole application into one bytecode executable before
   compilation is not tractable at this size: the dependency graph
   is too large, incremental rebuilds become necessary, and
   `dune`-driven test runners assume per-library compilation. The
   linker also has to assemble globals, relocations, and primitive
   tables on the fly. *(Reader + partial linker landed; driver and
   CLI integration outstanding — tracked in `ALIGNMENT.md`.)*

2. **Full `Stdlib` module-record materialisation.** Unblocks
   `invalid_arg`, `Printf` / `CamlinternalFormat`, `Lazy`,
   `module rec`, and the non-inlined `Obj` entry points. Core
   exercises every one of these pervasively; you will hit all of
   them in the first hour. Currently we sidestep some by binding
   `external`s directly — that won't scale to library code you
   don't own. Following jsoo's lead here: Stdlib is not
   precompiled ahead of time; it is linked into every build from
   `$(ocamlc -where)/stdlib.cma` alongside user code. The
   separate-compilation linker from item #1 already does most of
   what's needed — the remaining work is wiring Stdlib into the
   default input set and making the full module record flow
   through without gaps.

3. **Integer width — commit to a 63-bit-clean representation.**
   Anything that handles balances, block heights, nonces, or other
   quantities via `Int64` / unsigned arithmetic will silently wrap
   at the JVM 32-bit boundary. This is a correctness issue, not a
   performance one; it must be fixed *before* any such code runs,
   or you are debugging ghost bugs indefinitely. jsoo's `long`-
   for-`nativeint` approach is the precedent.

4. **64 KB method splitting.** Derived functors (`bin_io`,
   `sexp_of`, `compare`) plus heavy `ppx_deriving` / `ppx_jane`
   expansion generate long straight-line functions. The
   class-file `Code` attribute caps at 65 535 bytes. We haven't
   hit this yet because our test surface is small; at production
   scale we will, and the jsoo escape hatch (spill into auxiliary
   methods) is the blueprint.

5. **Broader C-primitive coverage.** File I/O
   (`caml_sys_open`, `caml_ml_input`, `caml_ml_input_char`, …),
   hashing, `Bigstring` / `Bigarray`, randomness, and whatever
   domain-specific stubs a caller ships. A strategy for the
   application's own C stubs is needed too: probably JVM-native
   reimplementations dropped into `runtime-java/`, or JNI bridges
   for anything that absolutely must stay C.

6. **Minimal concurrency story.** The application's async /
   lightweight-thread scheduler is not OCaml 5 effects — it's a
   monadic CPS layer over a scheduler that needs `Thread`,
   `Mutex`, `Condition`, and a real event loop. These can be
   stubbed to `java.util.concurrent` primitives, but nothing
   concurrent runs until they exist.

## Phase B — making the test pipeline usable

7. **`ppx_inline_test` / `ppx_expect` runner integration.** A
   JVM-side runner that plays the role of `inline_test_runner`,
   invokable via a new CLI sub-command or external driver.
   Without it there is no way to *run* the application's tests
   even when things compile.

8. **Source-map granularity.** Debugging stack traces through
   Core's functor layers with only block-start line numbers is
   impractical at this size. Per-expression `LineNumberTable` plus
   probably `SourceDebugExtension` (SMAP / JSR-45) so mainstream
   JVM IDEs can step through generated code.

9. **`check-runtime` / primitive registry.** Catches missing
    primitives at link time rather than after a long test run
    hits a stub exception.

10. **`StackMapTable` / Java 6+ verifier.** If any JVM-side test
    harness (JUnit, modern agents) insists on modern class files,
    Java 5 output becomes a blocker.

## Phase C — performance (only matters once Phase A/B works)

11. `Flow.Info.t` — the gating item for the whole optimiser layer.

12. Layer on Flow: stronger `Eval` → `Inline` → `Global_deadcode`.
    Core's "zero-cost" abstractions assume aggressive inlining;
    without it the application runs, but slowly.

13. `Closure_conversion` / `Curry` refactor — cleanup, not
    blocking.

14. Dead-param elim in `Deadcode` — small local win, fits anywhere
    after `Pure_fun`.

15. `Shape` inference — layered on Flow.

## Phase D — deferrable

Effects / CPS translation stays here: a caller application
doesn't use OCaml 5 effect handlers. Its async story predates
effects and is monadic.

`Target_sig` only pays off with a second backend.

## What moved vs. the generic ALIGNMENT.md ordering

| Item | Generic priority | Target-driven priority |
|------|------------------|------------------------|
| `from_cmo` / `from_cma` + link | mid | **#1** |
| Full Stdlib materialisation | mid | **#2** |
| Integer width | "as needed" | **#3 (correctness blocker)** |
| 64 KB method splitting | "when we hit it" | **#4** |
| Broad C-primitive coverage | ad-hoc | **#5** |
| Concurrency / Thread runtime | deferred | **#6** |
| Inline-test runner | not listed | **#7 (new)** |
| Source-map granularity | mid | **#8** |
| `Flow` + optimiser layer | **top of deferred** | **#11 (demoted)** |
| Effects | mid | **Phase D** |

(Precompiled-Stdlib caching was initially listed as Phase A but
dropped after reviewing jsoo's architecture: jsoo recompiles Stdlib
on every invocation and it's fast enough, so we follow suit. If
build times become a pain point we can cache the IR after
`Parse_bytecode.from_cma` as a targeted optimisation — tracked in
`ALIGNMENT.md`.)

The high-level reshuffle: the optimiser layer moves from
"do this next after the IR lands" down to "once the thing runs".
Separate compilation, Stdlib materialisation, integer width, and
the concurrency runtime move up from "eventually" to "before any
serious code touches the compiler". Everything I/O- or
concurrency-related becomes mandatory rather than optional.

## How this document relates to `ALIGNMENT.md`

`ALIGNMENT.md` is the canonical roadmap and is what gets updated
as items land. This file is a lens on that roadmap for one
specific goal. If the two ever disagree, `ALIGNMENT.md` wins —
update this file to match, or delete it if a caller profile is
no longer relevant.
