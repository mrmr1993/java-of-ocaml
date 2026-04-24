# Investigation: Java-facing facade classes for OCaml modules

**Status:** design / investigation only — no implementation started.
**Scope:** what it would take to make the class files emitted by
`java_of_ocaml` directly reusable from hand-written Java (or Kotlin,
Scala, etc.) callers, framing an OCaml module as a Java class with
its exported values exposed as static methods / fields.

## 1. Motivation and framing

Today the compiler's output is designed for *running* an OCaml
program on the JVM, not for *being called into* from other JVM
code. In concrete terms:

- The entry point is `Main.main`, which performs module
  initialisation in dependency order and then runs the bytecode's
  `STOP`.
- Each OCaml function becomes a `Closure` subclass named
  `ocaml_fn_<defname>_<N>` (synthesised from the DBUG `defname` plus
  a running counter — see `compiler/lib-java/compile.ml:884`). The
  class has a non-static `apply(...)` method; the environment's
  captures live in `cap0`, `cap1`, ... instance fields.
- A module's "value" is the OCaml-level module record: a `Block`
  (from `runtime-java/Block.java`) held in the `GLOBALS` array on
  the `Main` class. Exported bindings are fields of that block, at
  indices determined by `ocamlc`'s `Symtable.global_map` layout.
- There are per-unit init methods (`init_<Modname>` on `Main`, see
  `main_init_split.ml`) that populate the slots in `GLOBALS`.
- Primitives (C stubs / FFI) flow via a separate mechanism: the
  `stub_registry` + `--stub-manifest` path binds an OCaml primitive
  name (like `integers_uint32_add`) to a chosen
  `ClassName.methodName` with a chosen JVM descriptor.

A Java caller that wanted `Stdlib.List.length` today would have to:

1. Invoke `Main.main(new String[0])` first (to run init).
2. Reach into `Main.GLOBALS[n]` at the right index.
3. Unwrap the module block, pull out field `k` (the `length`
   closure), cast to `Closure`, and call `apply(list)` — fighting
   the verifier and the kind system for every argument.

Even with that, the caller has no static type information and no
idiomatic Java surface. The question is whether we can narrow the
gap programmatically — ideally without turning the backend into an
OCaml-to-Java source compiler (which it is not, and shouldn't
pretend to be).

## 2. What already exists that the design can reuse

Several pieces of infrastructure land close to what a facade layer
needs. Listing them explicitly because each subtracts work from any
feasible proposal:

- **Per-unit dispatch.** `Main_init_split` already splits
  main-init into one `init_<Modname>` method per compilation unit
  on `Main`. Each of those methods, when called, leaves that
  module's `GLOBALS[i]` populated. A facade can safely assume that
  a targeted `Main.init_Foo()` has been run (or orchestrate the
  required prerequisites — `cu_required` captures the dependency
  DAG in `Bytecode.unit_info`).
- **Function arity is known pre-codegen.** The CLOSUREREC /
  CLOSURE pre-scan in `compile.ml` (see `find_functions`,
  `function_info.ml`) records `nargs` and the emitted class name
  for every OCaml function before IR lowering starts. So the
  facade would know whether an exported binding is a 1-, 2-, ...,
  7-ary function or a non-function value, without any new
  analysis.
- **Kind inference.** `Jvm_typing.infer` already assigns a
  `Kind.kind` to every Var and to captures / arg slots of every
  closure. Return kinds and argument kinds of exported functions
  are reachable as a side-effect of normal compilation. Nothing
  new is needed to know "the third arg is an `int`, the second is
  a `Block` with these field kinds".
- **Convert-on-assign idiom in `Jvm_generate.emit_store`.** The
  coercion logic between `K_obj` / `K_int` / `K_float` / `K_string`
  / `K_block` is already in one place. A facade's JVM descriptor
  can borrow `Kind.descriptor_of_kind` to build param/return
  descriptors and reuse the same box / unbox sequences on each
  side of the dispatch.
- **Stub manifest pattern.** `stub_registry` already handles
  "user provides JSON naming some OCaml C primitives, compiler
  wires them to `ClassName.methodName` with given descriptor".
  This is the exact shape a facade description would take in
  reverse (Java code calling into OCaml rather than OCaml `extern`
  calling Java), and its JSON / CLI plumbing can be lifted with
  very few changes.
- **PPX+FFI for the other direction.** `ppx_java` + `Java.Unsafe`
  show a working pattern for "user-directed cross-language
  surface, compiler honours a description". The facade is the
  mirror of this.
- **Module-name tagging in the bytecode.** Each `Bytecode.Unit.t`
  carries its `modname`, and if the input is a `.cmo`/`.cma`
  we also have `cu_name`, `cu_imports`, `cu_required`, etc.
  Everything needed to identify which compilation unit owns which
  `GLOBALS[i]` slot is already threaded through.

## 3. What the bytecode *can't* tell us

This is where most of the design friction lives. The bytecode
executable carries only:

- The compiled code + global indices.
- DBUG events (file, line, column, module name, enclosing
  defname). Enough for human-readable error messages, not enough
  to reconstruct types.
- Relocation metadata naming units and primitives.

It does not carry:

- Source-level **types** — not even arity of a non-function
  module binding (a `string ref` binding is indistinguishable
  from a `string` binding in raw bytecode).
- **Field-name ↔ index mapping** for module-level bindings beyond
  what `Symtable.global_map` exposes (names of *globals* — the
  module-record itself — but not names of the fields that are
  bindings within that module record).
- **Variant / record constructor names.**
- **Label / optional-argument** information; those are compiled
  away into positional closures with default-fill helpers by the
  time we see them.
- **Functor argument arities / shapes.** A functor becomes a
  closure at module-init time. From bytecode alone it looks like
  any other function.

These gaps imply that any automatic facade extraction from bytecode
alone (no `.cmi`, no `.cmti`, no user input) is structurally
limited to: "here is a module, here are its N exported fields in
positional order, each one is opaque unless it happens to be a
closure of some known arity, in which case we know how many `Object`
arguments it takes". Usable as a low-level bridge; not usable as
an idiomatic Java API. So the investigation splits along whether
the user supplies more information.

## 4. Design space

Ordered from least to most user-facing information required.

### 4.1. Manifest-only (user describes the surface)

User writes a JSON/TOML description per module they want exposed:

```jsonc
{
  "module": "MyLib.Int64_utils",
  "class": "com.example.Int64Utils",
  "bindings": [
    { "ocaml": "add",        "java": "add",
      "descriptor": "(JJ)J",
      "arity": 2, "return_kind": "K_int" },
    { "ocaml": "of_string",  "java": "parse",
      "descriptor": "(Ljava/lang/String;)J",
      "arity": 1, "return_kind": "K_int" }
  ]
}
```

The compiler emits `com/example/Int64Utils.class` with static
methods of the declared descriptors. Each method body:

1. Looks up the module block in `Main.GLOBALS[module_idx]`,
   running any required `init_*` prerequisites first (a cached
   boolean guards against re-init; the existing per-unit init
   structure makes this mechanical).
2. Loads the given field index from that block to obtain the
   closure.
3. Unboxes / boxes parameters per the `kind` spec (mirroring
   `emit_store`) and calls `Closure.apply` with the expected
   arity.
4. Coerces the return value back.

**Pros.**
- No new analysis, no `.cmi` reader, no ppx coupling.
- Handles the 90% case: "this OCaml library exposes twenty
  `int64 -> int64` functions and I want to call them from Java".
- Symmetric in spirit with the existing `stubs.json` model:
  one JSON file per library. Reuses JSON parsing + CLI plumbing.
- Trivial incremental rollout: you can describe one function at
  a time.

**Cons.**
- User has to restate OCaml types in JVM descriptors. A mismatch
  between what the OCaml side actually produces (e.g. a boxed
  `Long`) and what the facade claims (an unboxed `J`) is a runtime
  `ClassCastException` in code Java callers didn't write.
- Global field indices are not stable across recompiles if the
  surface of the module changes. You would pin the *name*
  (`bindings.ocaml = "add"`) but resolution back to a numerical
  field index requires either (a) reading the `.cmi` of the
  module to recover the position of the binding in the module
  struct, or (b) exposing `Symtable.global_map` down to the
  field level, which it doesn't directly do — you'd need to read
  the module signature anyway. So in practice this approach
  can't avoid touching `.cmi`.

**Verdict.** Easiest to implement, hardest to make reliable
across rebuilds without a `.cmi` reader. Probably the right
landing place for a first experiment, but only once the
index-resolution story is honest.

### 4.2. `.cmi`-driven, whitelist-based (user names modules)

User passes `--export-module MyLib.Foo --export-module MyLib.Bar`
at compile time. For each named module the compiler:

1. Locates the matching `.cmi` on a user-supplied path, reads it
   via `compiler-libs`' `Cmi_format` + `Types`. (This is the
   blessed public entry point — consistent with the CLAUDE.md
   guidance against `Obj`-traversal of compiler internals.)
2. Walks `Types.signature` looking at `Sig_value`, `Sig_type`,
   `Sig_module`, `Sig_typext`, `Sig_class`, etc. Maps each
   `Sig_value` to a field index (they are emitted in signature
   order) and classifies its type.
3. Emits a facade class `<package>.<Module>` with one static
   method per value binding. Signature translation:
   - `int`, `bool`, `char` → `int` (JVM). Booleans need the
     standard 0/1 encoding on the Java side.
   - `int64` → `long`.
   - `float` → `double`.
   - `string`, `bytes` → `java.lang.String` /
     `java.lang.StringBuilder`.
   - `'a -> 'b` → `apply` on a returned `Closure` wrapper. A
     curried n-ary function is rendered as either a method
     taking all arguments positionally (eager saturation) or a
     method returning a typed `FunctionN<...>` wrapper.
   - Tuples → a generated `record`-like value class (or a
     `java.util.List`-based accessor pair).
   - Records → a generated value class with field accessors
     named after the record labels.
   - Variants — see §5.4.
   - Abstract types (`type t`) — leave as opaque handle; emit
     a `public final class T { private final Object block; ... }`
     with a package-private constructor. Callers can only do
     identity/equality and pass them back in.
   - Polymorphic (`'a list -> int`) — erase to `Object`; let
     the caller use `@SuppressWarnings("unchecked")` on the
     Java side or emit a generic signature via the JVM
     `Signature` attribute (classfile v49 supports it).

**Pros.**
- No user work beyond a flag and a path. For libraries that
  already have decent type signatures, the facade is as good
  as the OCaml types.
- Rebuild-safe: field indices are recomputed from the current
  `.cmi` every compile.
- Reuse of `compiler-libs.Types` is well-trodden ground — this
  is what the OCaml toplevel, `odoc`, `ocaml-lsp`, and `ppx`
  ecosystems all do.

**Cons.**
- Adds a dependency on `compiler-libs` to the compiler's
  runtime (currently only the bytecode reader goes through
  `compiler-libs.bytecomp` for `Symtable`, which is a very
  narrow surface). More code to keep aligned across OCaml
  versions, on top of the existing 4.14/5.x split in
  `bytecode_compat`. `Types.signature` has changed shape across
  4.14 → 5.x (e.g. `Sig_value` fields) so the shim pattern will
  need extending.
- Still leaves all the *design* questions open (currying,
  variants, functors, etc. — see §5).

**Verdict.** The natural second step. This is where the
feature stops being a toy. `.cmi` reading is also reusable for
other planned work (better missing-primitive diagnostics,
Stdlib module-record materialisation tracked in
`docs/PRIORITIES.md`).

### 4.3. Annotation-driven (user annotates source with a PPX)

`[@@java.export "com.example.Foo"]` on a module, or
`[@@java.export_as "add"]` on a binding, emits the facade at
compile time. The PPX embeds the export metadata in a custom
section of the `.cmo` (bytecode `EXTRA` sections are a supported
mechanism) which the backend reads.

**Pros.**
- Co-located with the source of truth. A library author can
  version the Java surface alongside the OCaml code. Refactors
  that rename an OCaml binding without updating the export
  annotation are caught at `ocamlc` time.
- Gives the user a place to override names, adjust visibility,
  declare intended Java generics, etc.
- Scales per-binding, not just per-module.

**Cons.**
- Requires a new PPX and a new bytecode section convention.
  More moving pieces to version.
- The annotation has to resolve to types the backend can read
  — so it still depends on §4.2's infrastructure. This
  approach is additive to §4.2, not a substitute.

**Verdict.** Worth designing now so §4.2's manifest format and
§4.3's attribute payload coincide, but no need to build it
until there's a user who wants it.

### 4.4. Full module-as-class lowering

A more ambitious path: stop compiling modules to `GLOBALS[i] +
Block`, and instead emit each module as a real Java class with
static fields (constants) and static methods (functions). The
facade *is* the module.

**Why we should not do this now.**
- The representation choice is load-bearing. `GLOBALS` + `Block`
  is how OCaml's recursive module init, functor instantiation,
  `module rec` / `CamlinternalMod`, first-class modules, and
  run-time introspection (`Obj.field`) all work. Ripping that
  out means re-implementing all of it in a Java-native idiom,
  and several of those features don't have natural
  Java-native idioms.
- It would bifurcate the backend into "modules that happen to
  have been chosen for native lowering" vs "modules that
  didn't", with cross-calls needing adapters in both
  directions. The complexity of the adapter layer is
  comparable to just keeping the uniform representation and
  generating facade wrappers on top (§4.1–§4.3).
- `wasm_of_ocaml` did not go this way, and the architectural
  intent of this project is to track `wasm_of_ocaml`.

Noting this path exists so it doesn't get proposed later
without its costs being explicit.

## 5. Design questions that any of the above must answer

### 5.1. Currying

OCaml's `f : int -> int -> int` is *one* function that returns a
function. In the current representation:
- If the closure was emitted with arity 2 (the usual case), a
  single `apply(x, y)` invocation satisfies it. Undersupplied
  calls spawn a `PartialClosure`.
- Java callers will most naturally want `int add(int, int)`, not
  `Function<Integer, IntUnaryOperator>`.

**Recommendation.** Emit one Java method per *arity* of the
closure as it was compiled (available from `function_info.nargs`
at codegen time). For exports that want a genuinely curried
signature, emit a `FunctionN<...>` wrapper as an additional
static method. Don't expose `PartialClosure` across the FFI
boundary — it is an implementation detail.

Edge case: closures compiled at an inner arity and then `GRAB`-ed
up to a higher one at call sites. The pre-scan's `nargs` is
already the observable arity, not the body's. Good.

### 5.2. Exceptions

OCaml exceptions are `CamlException` (see
`runtime-java/CamlException.java`), an unchecked `RuntimeException`.
A Java caller would see a `CamlException` bubble out. Options:

- Leave as-is — caller catches `CamlException` and reads the
  wrapped `Block` to inspect the OCaml exception. Low friction,
  low discoverability.
- Generate per-exception Java subclasses — would need
  `.cmi` type info (`Sig_typext`) to know which exceptions a
  module can raise. OCaml's type system doesn't track
  exception effects, so "can raise" is not a real invariant;
  you'd have to document it.
- Generate a thin wrapper that re-throws as
  `IllegalArgumentException` / `NoSuchElementException` for the
  common cases (`Invalid_argument`, `Failure`, `Not_found`).
  Brittle; the mapping would be hand-curated.

**Recommendation.** Leave as-is. Facade methods declare no
checked exceptions; the raw `CamlException` escapes. Document
the common identities (`Failure`, `Invalid_argument`, `Not_found`)
in the facade's javadoc.

### 5.3. Polymorphism / abstract types

Two sub-problems:

- **Polymorphic functions.** `List.length : 'a list -> int`. At
  runtime everything is `Block`/`Object` — the facade method
  signature is straightforwardly `int length(Object list)`.
  Emitting a JVM `Signature` attribute gives Java callers the
  generic `<T> int length(List<T>)` surface, at the cost of
  reading and rendering `Types.type_expr` correctly. Nice-to-have
  rather than necessary.
- **Abstract types.** `type t` in a `.mli` — callers mustn't
  construct one, mustn't peek inside. Emit an opaque handle
  class with a package-private constructor living in the same
  package as the facade; the facade's methods create and
  consume them. This is the standard "phantom-typed handle"
  pattern; `Java.t` in our own FFI uses the same idea in the
  opposite direction.

### 5.4. Variants and records

For value-flow interop, records and variants need *some* Java
representation if callers are to read them.

Record `{ x : int; y : int }` → a generated value class with two
accessors. Needs `.cmi` for field names and kinds.

Variants split into:
- **Enums (all immediate, no payloads)** → Java enum. Clean.
- **Mixed (some payload, some immediate)** → sealed interface
  with one record per non-constant constructor and singletons
  for constants (Java 17+). Classfile version 49 (what we emit
  today) does not carry sealed-class metadata; we'd have to bump
  to at least 61. Mentioned below.
- **Polymorphic variants** — the hash-tag layout is stable,
  but Java has no natural representation. Advise: expose as
  opaque or not at all.
- **GADTs / existentials** — treat as opaque.
- **Extensible variants (`type t = ..`)** — fundamentally
  open-world, which Java's type system can't express beyond
  "root abstract class, anyone can subclass". Treat as opaque
  unless the user opts in explicitly.

### 5.5. Module init ordering

The facade has to guarantee that `Main.init_Foo` has run before
the first call into `Foo`. Options:

- Thread-safe one-shot: a `static volatile boolean initialised`
  on the facade class, checked on entry to every method; first
  call into any method triggers `Main.main(new String[0])` or a
  targeted `Main.init_*` chain derived from `cu_required`.
- `<clinit>`: run init in the facade class's `<clinit>`. Simpler
  but means loading the facade class triggers full init, which
  is unfriendly in test frameworks that load all classes
  eagerly.
- Explicit: expose an `init()` static method, require the user
  to call it. Leaky but honest.

**Recommendation.** Thread-safe one-shot on first method entry,
with an explicit `init()` escape hatch.

### 5.6. Mutable module-level state

`let counter = ref 0` is a `Block` in `GLOBALS[i]` at field `k`.
A facade that exposes `counter` as a `static int` field would
be out of sync with the OCaml side's cell. Correct handling:
expose it as a method pair (`int getCounter() / void
setCounter(int)`) that always round-trips through `GLOBALS`.
Eager evaluation of module-level `let x = f () in ...` is also
fine as-is: the value is whatever `init_Foo` left in the slot.

### 5.7. Functors

A functor is a closure at the bytecode level. Applying the
facade layer to the *result* of a functor application is
straightforward (it's just another module block in a `GLOBALS`
slot). Applying it to the *functor itself* is harder: the Java
caller would need to supply a module-block argument that
looks, structurally, like an instance of the functor's
parameter signature. This is possible but tedious and almost
certainly out of scope for a first pass. Advise: do not expose
functors directly; expose their already-applied instances.

### 5.8. Classfile version and sealed types

We currently emit classfile major version 49 (Java 5). Two
reasons that restricts facade quality:

- No `Signature` attribute parity with modern generics tooling
  (technically present since 49, but some IDE code paths only
  read it via modern verifier runs).
- No sealed classes (61+), no records (58+), no pattern
  matching for switch expressions (61+).

A facade-heavy workflow benefits from 61+. Doing this is a
separate piece of work (stack map tables become mandatory
starting at 51+), and it unlocks things far beyond this
feature. Mentioning it here to flag the linkage.

## 6. Interaction with separate compilation

`docs/PRIORITIES.md` § "Phase A" item 1 has `from_cmo` /
`from_cma` + separate-compilation link step as a prerequisite for
real-world use. The facade layer interacts:

- Manifest-driven facades can be emitted per-unit at per-unit
  compile time, using exactly the same per-unit init methods
  that `Main_init_split` already produces.
- `.cmi`-driven facades benefit from separate compilation too:
  the `.cmi` is available when its matching `.cmo` is compiled,
  so facade emission can happen alongside.
- Cross-unit facade references (facade for `Foo` mentions
  module `Bar` in its signature) need either (a) a shared
  handle class generated in a known package, or (b) emission
  of forward-declared opaque classes the first time they are
  referenced. The latter is the simpler choice.

Upshot: there is nothing in the facade design that forces it
to run in whole-program mode. Doing it per-unit lines up with
the compilation model `PRIORITIES.md` is converging on.

## 7. Concrete risks to flag

- **Field-index drift.** OCaml changes the emitted order of
  module-struct fields in response to source edits. Facades
  must resolve fields *by name* (via `.cmi`) at every
  compile, never cache indices across runs. A facade-lookup
  failure should be a loud compile-time error, not a silent
  runtime `ArrayIndexOutOfBoundsException`.
- **OCaml 4.14 vs 5.x `Types.signature` shape.** Extend
  `bytecode_compat` rather than branching per-call-site.
- **`compiler-libs` version pinning.** The compiler currently
  needs the same compiler-libs that built the bytecode for
  `Symtable.global_map`. Adding `Cmi_format` + `Types`
  widens that coupling surface; the 4.14/5.x split already
  in `bytecode_compat` will likely need a matching pair for
  the type reader.
- **Security surface.** Exposing OCaml modules as Java-callable
  means any untrusted Java code can invoke them. OCaml has
  essentially no sandboxing model; neither does the JVM.
  Worth a one-line note in the facade's generated javadoc
  that the module was exposed deliberately.
- **Dead-code elimination.** `Deadcode` currently prunes
  unreachable blocks inside closures, but closure classes
  themselves are emitted unconditionally. A facade creates
  a new reachability root — there should never be a case
  where the facade references a closure class the backend
  decided not to emit, but it's worth a cross-check.
- **Inline tests / `ppx_inline_test`.** Tests live in the
  same modules they exercise. If a module with inline tests
  is exposed, the facade will (harmlessly) skip the test
  closures but their init code still runs at `init_*` time.
  `PRIORITIES.md` notes this is a first-class use case; the
  interaction is worth revisiting once the inline-test
  runner lands.
- **Initialisation re-entrancy.** If a facade method is
  called from a Java thread while `Main.main` is running on
  another thread, the one-shot init guard must agree with
  the main-init path. Easiest: the facade calls into the
  same `init_*` methods `Main.main` does, sharing the same
  `GLOBALS`-is-populated invariant.

## 8. Recommended sequencing

If/when we start building this:

1. **Lift a small, explicit CLI surface** —
   `--export-module NAME --export-class FQCN`. Start from
   `.cmi`-driven emission (§4.2) but keep the manifest path
   (§4.1) as a parallel entry point; they share most of the
   emission code.
2. **Stand up `.cmi` reading via `compiler-libs.Cmi_format`**
   behind a `bytecode_compat`-style version shim. Cover only
   `Sig_value` translation to start — not variants, not
   records.
3. **Emit a single facade class** for one chosen toy module
   with `int`, `long`, and `string` bindings. Prove the
   init-guard + dispatch story end-to-end against a hand-
   written Java caller. Snapshot under
   `compiler/tests-compiler/java_facade.ml`.
4. **Expand type coverage** — floats, tuples, records,
   enum-only variants — one at a time, each with its own
   expect-test.
5. **Document what is and isn't reachable.** Keep that list
   in this file; prune as items land. Functors, polymorphic
   variants, GADTs, extensible types, exceptions-as-
   subclasses all live below the "ambitious" line.
6. **Only then** consider the PPX layer (§4.3). It is purely
   additive and should be evaluated against real library
   authors' demand, not speculative demand.

## 9. What this investigation explicitly does not propose

- Changing the current representation of modules (Block in
  `GLOBALS`). §4.4 remains an architectural dead end for now.
- Generating Kotlin, Scala, or other language-specific
  surfaces. JVM-compatible is enough; language-specific sugar
  can ride on top externally.
- Source-level interop in the other direction (Java classes
  exposing themselves as OCaml modules). That is what
  `ppx_java` + `Java.t` already do; it is not in scope here.
- Sandboxing, security review, or any attempt to make the
  facade surface safe to expose to untrusted callers.

## 9.5. Findings from an exploratory test run

After step 3 landed the end-to-end emission path, we pointed the
facade at two representative modules reachable from a large
externally-built bytecode executable — one whose top-level
signature exposed only nested modules (no direct `val`s), and
`Stdlib__Int64` as a pure-stdlib control. Results:

- **A nested-module-only signature emits zero methods.** When a
  module's public API is composed entirely of nested modules
  (`module Fee : Basic`, `module Amount : Basic`, ...) with no
  direct `val` bindings at the outer level, the step-3 classifier
  walks past the outermost signature and finds nothing to surface.
  The tool correctly reports "no supported bindings; no class
  emitted" rather than crashing. This is the expected landing
  for step-4 work: descend into `Sig_module`, generate one facade
  class per nested module, and wire the nested module's field
  index off its parent's module block.
- **`Stdlib__Int64` emits 16 static methods.** `zero`, `one`,
  `minus_one`, `max_int`, `min_int`, `succ`, `pred`, `abs`,
  `lognot`, `unsigned_div`, `unsigned_rem`, `to_string`, plus the
  setup surface. `compare`, `equal`, `min`, `max`, `of_string_opt`,
  `unsigned_to_int`, and several others skip cleanly with the
  documented stderr warning — their signatures use types the
  first-landing classifier keeps as `K_other` (polymorphic
  `('a, 'a) -> int` for `compare`, `int option` for `of_string_opt`,
  etc.). All skip cases are in the step-4 backlog already.
- **Dispatch reaches OCaml land.** Calling a facade method from a
  hand-written Java driver goes through the facade's init guard
  into `Main.main`, which then runs the target bytecode's regular
  main-init. On the exploratory target this halted at a pre-
  existing unimplemented C-primitive stub in an upstream
  dependency — exactly matching the stub-path behaviour of plain
  `java Main` on that bytecode. The facade itself transmitted the
  call correctly; the failure was in the target binary's main-init,
  not in the facade layer.

**Operational implication surfaced by the run.** The current
one-shot init model calls `Main.main(new String[0])` at the first
facade invocation. For a binary with a failing main-init this
means the facade can't be used even for modules that would
themselves run cleanly. The natural refinement (flagged in §5.5)
is: resolve `cu_required` transitively for the target module and
invoke only the relevant `init_<Modname>` helpers in order,
stopping before the failing unit. That changes the init-guard
shape from "one-shot entire-program" to "targeted partial init"
and is the most impactful step-4+ item once nested-module
coverage lands.

## 10. One-line summary

A manifest- or `.cmi`-driven facade layer emitting thin static-
method classes on top of the existing `Main.GLOBALS` + `Closure`
machinery is a tractable, bounded, user-opt-in extension.
Nothing in the backend needs to change; the facade sits as a
post-pass consuming information (arity, kinds, module names)
the compiler already produces, enriched with `.cmi` signatures
for anything beyond raw positional access. Start with one
module, one type (`int` / `long`), one descriptor form, and
expand from there.
