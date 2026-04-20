# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**java-of-ocaml** compiles OCaml bytecode (full executables from
`ocamlc`, or a set of `.cmo` / `.cma` files linked together) to JVM
class files. It is modeled after `wasm_of_ocaml` (the WASM backend
in `js_of_ocaml`), which compiles OCaml bytecode to WebAssembly.

The project uses a local opam switch with OCaml 5.3.0 and dune 3.17.
A secondary 4.14.2 switch (`./.opam-4.14`) lets the same codebase
ingest 4.14-built bytecode — a tiny `bytecode_compat` shim, selected
by dune via `%{ocaml_version}`, normalises 4.14's and 5.x's
incompatible `Cmo_format` relocation variants into one shape.

## Architecture

Compilation is a single pass with no legacy / fallback paths:

```
.bc / .cmo / .cma                 — input bytecode
  → Bytecode.read_exe / Linker.link
                                  (CODE / PRIM / DATA / SYMB + reloc)
  → Instr.decode_all              (→ Instr.instr array)
  → Parse_bytecode.parse_{main,function}
                                  (→ Code.program)
  → Eval + Deadcode (optional)    (→ Code.program)
  → Jvm_typing.infer              (per-Var Kind.kind)
  → Method_split.split            (if the method would exceed 64 KB)
  → Jvm_generate.emit_program     (→ Jvm.Code.t per method)
  → Jvm.assemble_class            (→ .class bytes)
```

`Code.program` is a strict-SSA IR adapted from
`js_of_ocaml/compiler/lib/code.ml`: basic blocks with explicit
`params : Var.t list`, straight-line instruction bodies (`Let` /
`Set_field` / `Offset_ref` / `Array_set` / `Source_pc`), and `last`
terminators (`Return` / `Raise` / `Stop` / `Branch` / `Cond` /
`Switch` / `Pushtrap` / `Poptrap` / `Invoke_tail`). Every cross-block
value flows through a dedicated JVM local. Block-edge parallel
renames coerce each arg to a caller param's declared kind —
same convert-on-assign idiom as jsoo's `lib-wasm/generate.ml`.

Key invariants:
- Strict SSA. `Let (x, e)` binds a fresh `Var.t`, and that's the
  only way to define a Var. OCaml bytecode's `ASSIGN` is handled
  by the parser reseating the stack slot's `Var.t` rather than
  emitting a re-definition — so every Var has exactly one def.
  Downstream passes rely on this (most notably `Method_split`,
  which forwards live-through vars at a cut without needing
  per-predecessor dominance analysis).
- `Switch` carries both int- and tag-case arrays in one terminator.
- Universal carrier is `java.lang.Object`. Primitives (`int` /
  `double`) are an unboxing optimisation, not a requirement. Block
  params default to `K_obj`; downstream uses unbox on demand via
  `emit_store`'s coercion from the producing kind.
- Apply-method locals 1..N are the formal args by JVM calling
  convention; `emit_program` pre-binds each arg Var to its local
  so `emit_load arg_i` reads from the right slot.
- The env Var (the current closure's `this`) maps to `aload 0`.
  `Field(env, i)` resolves to a capture-field read on the enclosing
  function's class; `Prim (Extern "offsetclosure", [env; k])`
  resolves to the sibling-field lookup.
- Trap regions are stack-relative, not block-relative.
  `Code.compute_trap_contexts` derives the active-trap stack at
  every reachable block by forward DFS from `prog.start`. Both
  `Method_split` (for cut validation) and `Jvm_generate` (for
  JVM exception-table entries) consume the resulting map so that
  nested try/with is laid out correctly even after structural
  splits. Two paths reaching the same block with different trap
  contexts fail loudly.
- Method splitting. `Method_split.split` rewrites any program
  whose emitted body would exceed the JVM 64 KB `Code`-attribute
  limit into a head method plus `Invoke_tail` helper methods,
  with `Code_cost.program_upper_bound` / `program` as cheap
  size estimators. Intra-block chunking handles individually
  oversized blocks; CFG cut-point search handles the rest. Cuts
  are always validated against trap regions.

## What's implemented

Every feature below is covered by at least one test under
`compiler/tests-compiler/`. `dune runtest` runs the whole suite.

- **Values** — ints (primitive JVM `int` where possible; boxed as
  `java.lang.Integer` when crossing into `Object`-typed slots),
  strings (JVM `String`), tuples, records (mutable and immutable),
  arrays, lists, refs, variants (option, enum, mixed immediate/data,
  polymorphic, extensible via `type t = ..`), GADTs, inline records
  in variants.
- **Control flow** — if/else, branches, `for`, `while`, tail calls,
  exceptions (`raise` + `try ... with _`, or matching specific
  exceptions via reference equality on descriptors).
- **Functions** — up to 7-ary, non-tail calls, recursion, mutual
  recursion (`CLOSUREREC` with `nfuncs > 1`), closures capturing
  anything, partial application (undersupplied calls produce a
  `PartialClosure` that delays until saturation).
- **Modules** — structures, signatures, nested modules, aliases,
  `open` (top-level and local), functors (single-arg, multi-arg
  curried, generative `()`), `include`, `with type` and `with type
  :=`, `module type of`, first-class modules.
- **Recursive values** — `let rec a = A (b, b) and b = [|a; a; a|]`
  via `caml_alloc_dummy` / `caml_update_dummy`.
- **`Obj`** — the inlined externals (`%identity`, `%obj_is_int`,
  `%obj_size`, `%obj_field`, `%obj_set_field`) and the C primitives
  `caml_obj_tag`, `caml_obj_block`, `caml_obj_with_tag`,
  `caml_obj_dup`. Non-inlined entry points like `Obj.is_block` work
  when linking against `stdlib.cma`.
- **`Int`** — `neg`, `succ`, `pred`, `add` / `sub` / `mul` / `div` /
  `rem`, `logand` / `logor` / `logxor`, `shift_left` / `shift_right`
  / `shift_right_logical`, and the matching infix operators. Shifts
  are JVM-int (32-bit), not OCaml's 63-bit, so programs that rely on
  the full width will diverge — tracked in `docs/ALIGNMENT.md`.
- **`Float`** — `+.` / `-.` / `*.` / `/.`, unary `-.`, `Float.abs`,
  NaN-safe comparisons (via `dcmpl` / `dcmpg`), `int_of_float` /
  `float_of_int`. Floats flow as JVM `double`, boxed to
  `java.lang.Double` when crossing into `Object`-typed slots.
  Float locals are 2-wide (`Kind.local_slots_for_kind`).
- **`Int64` / `Nativeint`** — bit-accurate 64-bit arithmetic via
  native JVM `long` ops (`ladd` / `lsub` / `lmul` / `ldiv` /
  `lrem` / `lneg` / `land` / `lor` / `lxor` / `lshl` / `lshr` /
  `lushr` / `lcmp`). Values flow as boxed `java.lang.Long`.
  `caml_int64_float_of_bits` / `_bits_of_float` use
  `Double.longBitsToDouble` / `doubleToRawLongBits`, so stdlib's
  `infinity` / `nan` / `max_float` / `min_float` initialise to
  the correct bit patterns.
- **`Array`** — `Array.make`, `Array.length`, safe and unsafe indexed
  get/set, `caml_array_sub` / `caml_array_blit` / `caml_array_fill`
  / `caml_array_append`. Arrays are the `Block` representation.

### Stdlib + primitive coverage

- **I/O** — `print_endline`, `print_string`, `print_int`,
  `print_newline` compile through `caml_ml_output` /
  `caml_ml_output_char` / `caml_ml_flush` /
  `caml_ml_open_descriptor_out`, backed by the `Channel` runtime
  class (a `java.io.PrintStream` wrapper).
- **File I/O** — `open_in` / `open_out` / `input_char` / `input_line`
  / `input` / `close_in` / `close_out` / `Sys.remove` compile through
  `caml_sys_open` / `caml_sys_close` / `caml_sys_remove` /
  `caml_ml_{input,input_char,input_scan_line,close_channel}`, backed
  by `Channel`'s buffered input mode (64 KB byte buffer implementing
  the OCaml `input_scan_line` newline-search protocol). `End_of_file`
  is raised as a `CamlException` wrapping the descriptor at
  `GLOBALS[4]` — the main-init prelude seeds `Channel.endOfFileExn`
  right after globals init.
- **String concat** — `(^)` via `caml_create_bytes` /
  `caml_blit_string` / `caml_string_of_bytes` / `caml_bytes_of_string`
  / `caml_bytes_{get,set,equal,compare}`, backed by the `Bytes`
  runtime class (a `StringBuilder` wrapper).
- **List** — `List.length`, `List.fold_left`, `List.iter`, `List.sort`.
- **Exception helpers** — `invalid_arg s` / `failwith s` / `raise
  Not_found` round-trip through `try … with Invalid_argument _ |
  Failure _ | Not_found ->`; user-defined `exception E of …`
  constructors with args also match.
- **System constants** — `caml_sys_get_config` returns the
  `("Unix", 32, false)` triple `Sys` destructures; `caml_sys_const_*`
  for the integer sub-constants.
- **Structural comparison** — `caml_equal`, `caml_notequal`,
  `caml_compare`, `caml_lessthan`, `caml_greaterthan`,
  `caml_lessequal`, `caml_greaterequal` route through the `Compare`
  runtime class.
- **`Bigarray`** — `Array1.create` / `get` / `set` / `dim`, `Array2.get` /
  `set`, `Genarray.{dims,kind,layout,blit,fill}` via the `BigArray`
  runtime class (boxed `Object[]` storage per cell, supports any
  kind/layout combination). Fast enough for setup paths like
  `Random.State` but every access boxes — hot users should get a
  typed-storage version later.
- **`Digest`** — `Digest.string` / `bytes` via `caml_md5_string` /
  `caml_md5_bytes`, backed by `java.security.MessageDigest`. Return
  value is a `java.lang.String` (matching OCaml's `Digest.t = string`).
- **`Random`** — `Random.State.make_self_init` / `int` / `int64` /
  `float` / ... compile cleanly (stdlib's state is a 4-int64
  `BigArray` advanced by `caml_lxm_next`).
- **`Mutex` / `Condition`** — `Mutex.{create,lock,try_lock,unlock}`
  and `Condition.{create,wait,signal,broadcast}` backed by
  `java.util.concurrent.locks.ReentrantLock` (in `Mutex`) and a
  lazily-bound `Condition` (in `CondVar`). Behaves correctly under
  real contention; in the single-threaded case the lock ops are
  cheap and `signal` / `broadcast` are no-ops.
- **`Thread`** — `Thread.create` / `self` / `id` / `join` / `yield`
  via the `ThreadPrim` runtime class delegating to
  `java.lang.Thread`. Each OCaml thread is a Java thread running a
  `Runnable` that unwraps the OCaml closure and applies it. Requires
  linking against `threads.cma` for the OCaml-side API; the low-
  level primitives (`caml_thread_new` etc.) also need a handful of
  Unix init-stubs (`caml_unix_inet_addr_of_string` etc.) since
  `threads.cma` pulls in `Unix`.
- **`Lazy`** — `lazy expr` and `Lazy.force` round-trip through
  `CamlinternalLazy` + the four tag-transition primitives
  (`caml_lazy_update_to_forcing` / `caml_lazy_reset_to_lazy` /
  `caml_lazy_update_to_forward` / `caml_lazy_make_forward`).
  Single-threaded semantics: the CAS on the tag is a plain compare
  + set.
- **Java FFI** — user-declared `external f : ... = "java:<op>:..."`
  primitives emit direct JVM `invoke*` / `getfield` / `new`
  sequences. The `Java` library (`compiler/lib-java-runtime/`)
  exposes phantom-typed wrappers + `Java.Unsafe`; `ppx_java`
  (`ppx/ppx_java/`) adds `obj##meth` / `[%java.new]` /
  `[%java.static]` / `[%java.get]` / `[%java.set]` sugar that
  expands to calls through the reflective `JavaFFI` runtime class.

Unrecognised C primitives compile to a runtime-throwing
`UnsupportedOperationException` stub — the class loads cleanly and
the error only fires if the call path is actually reached.

### Not yet supported

- `module rec` — simple cases pass (`corecursion.ml` tests);
  deeper `CamlinternalMod`-driven patterns (recursive module
  records with full Stdlib wired through) still hit runtime
  failures.
- OCaml 5 effects; no OCaml-style allocator bridge (the JVM does
  the GC).
- Plain OCaml `int` still runs as JVM 32-bit `int` (not 63-bit);
  bitwise / overflow-sensitive code that expects OCaml's full
  width will diverge. `Int64` / `Nativeint` use JVM `long` and
  are bit-accurate.

### Reference submodules

- `ocaml/` — the OCaml compiler (pinned near 4.12.0-alpha1).
- `js_of_ocaml/` — the js_of_ocaml / wasm_of_ocaml compiler (pinned
  near 6.3.0).

Both are excluded from the dune build (via the root `dune` file) and
are for reference only.

## Build & test commands

```bash
dune build @all                            # Build everything
dune runtest                               # Run all tests
dune runtest compiler/tests-compiler       # The main ppx_expect suite
dune runtest compiler/tests-java_of_ocaml  # Standalone executable tests (byte mode)
dune runtest compiler/tests-full           # Library compilation tests
dune promote                               # Accept test output changes
```

Manual compile and run:

```bash
ocamlc -no-check-prims -g prog.ml -o prog.bc
_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe prog.bc -o out_dir
java -cp out_dir Main
```

Linking `.cmo` / `.cma` inputs directly is also supported:

```bash
_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe stdlib.cma user.cmo -o out_dir
```

Useful CLI flags during development:

- `--debug FLAG` — enable a debug trace (comma-separated or repeated).
  Equivalent to adding `FLAG` to `JAVA_OF_OCAML_DEBUG`.
- `--print-function PC` — dump the decoded bytecode for the function
  body at `PC` to stderr (diagnosing `no terminator in function
  body` etc.).
- `--print-ir PC` — dump the `Code.program` produced by the parser
  for the function body at `PC`, or the failure message if IR
  lowering couldn't handle it. Pass `0` to target the main init
  code.
- `--list-missing-prims` — don't compile; list every C primitive
  the input references but that the backend has no explicit handler
  for. Useful for planning coverage work on unfamiliar bytecode.

Performance tuning for very large inputs (hundreds of MB):

```bash
OCAMLRUNPARAM='s=32M,o=300' _build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe ...
```

Default GC settings make many thousands of minor collections + a
handful of compactions on a multi-MB heap; raising the minor heap
size + space-overhead shaves a meaningful chunk of wall-clock off
end-to-end compiles.

## Repository layout

Each module under `compiler/lib-java/` has a companion `.mli`.

### `compiler/lib-java/`

**Input & low-level emission:**
- `bytecode` — bytecode-executable reader. Decodes CODE, PRIM, DATA,
  SYMB. SYMB parsing goes through `compiler-libs.bytecomp`'s
  `Symtable.global_map` (do NOT re-implement via `Obj` traversal —
  that route is fragile across OCaml versions and has been explicitly
  ruled out).
- `bytecode_compat` — `Cmo_format` normalisation shim for 4.14 vs
  5.x. `bytecode_compat_4.ml` / `bytecode_compat_5.ml` are the two
  impls; dune picks one by `%{ocaml_version}`. Only the reloc
  variants and `cu_required*` field shape differ; the rest is
  passthrough.
- `linker` — `.cmo` / `.cma` linking. Concatenates code sections,
  resolves relocations across units, appends a trailing `STOP`
  terminator so the linked program behaves like a unified bytecode
  executable.
- `jvm_bin` / `jvm_constant_pool` / `jvm_code` / `jvm_class_file` —
  class-file construction. `jvm_bin` is the u1/u2/u4 buffer helpers;
  `jvm_constant_pool` is the `Cp` builder; `jvm_code` is the
  method-body builder (labels, exception entries, operand-stack
  accounting); `jvm_class_file` assembles a class from methods +
  fields + cp.
- `jvm_runtime` — re-exports the runtime-class byte blobs compiled
  from the Java sources under `runtime-java/`.

**Analysis & metadata:**
- `global_view` — `Gv_*` / `G_*` classification of `Obj.t` entries
  in the DATA section (integers, strings, floats, nested blocks).
- `instr` — decoded `instr = { pc; opcode; args }`, opcode
  classification (`is_c_call`, `is_acc`, `is_terminator`, …),
  branch-target arithmetic.
- `kind` — `kind = K_int | K_string | K_float | K_block of kind list
  | K_closure of closure_ref | K_obj` plus JVM descriptor / box /
  unbox / load / store helpers.
- `function_info` — per-OCaml-function metadata: class name, body pc
  range, nargs, ncaps, inferred capture kinds, CLOSUREREC group
  pointer.
- `prim` — the registry of supported C primitives
  (`prim_handler`, `find_supported_prims`).

**IR:**
- `code.ml` + `.mli` — the IR. `Var.t`, `Addr.t`, `constant`, `expr`
  (`Apply` / `Block` / `Field` / `Closure` / `Constant` / `Prim`),
  `instr` (`Let` / `Set_field` / `Offset_ref` / `Array_set` /
  `Source_pc`), `last` (`Return` / `Raise` / `Stop` / `Branch` /
  `Cond` / `Switch` / `Pushtrap` / `Poptrap` / `Invoke_tail`),
  `block`, `program`. Plus `Print` pretty-printers, `fold_children`,
  and `compute_trap_contexts` (per-block active-trap stack).
- `parse_bytecode.ml` + `.mli` — bytecode → IR. Block-boundary scan
  via `Instr.branch_targets` + terminator successors; a parser
  `state` threading accu + OCaml-stack slots + env; DFS over blocks
  with dynamic target-params promotion; per-opcode lowering covering
  every opcode `java_of_ocaml` emits (ACC / PUSH / CONST / arith /
  cmp / APPLY* / CLOSURE* / OFFSETCLOSURE* / ENVACC* / GETFIELD /
  SETFIELD / MAKEBLOCK* / BRANCH* / BEQ..BGE / BULTINT / BUGEINT /
  SWITCH / PUSHTRAP / POPTRAP / RAISE / RETURN / STOP / APPTERM* /
  RESUMETERM / REPERFORMTERM / C_CALL* / GRAB / RESTART / GETMETHOD
  / GETPUBMET / GETDYNMET / ATOM / float-block ops). Unsupported
  opcodes raise `Not_supported`.

**Optimisation & splitting:**
- `eval` — constant folding over IR (pure / cheap cases).
- `deadcode` — dead-block / dead-instruction elimination driven by
  reachability + `pure_fun` purity info.
- `pure_fun` — classifies exprs as pure (no observable effect) for
  deadcode to drop.
- `code_cost` — conservative per-instr / per-block / per-program
  byte-size upper bounds used by `method_split`. Cheap
  `program_upper_bound` (no per-instr walk) + exact
  `program` / `block` walks.
- `method_split` — splits a `Code.program` whose emitted body
  would exceed the JVM 64 KB `Code`-attribute limit into a head
  method plus `Invoke_tail` helper methods. Phase 1 is an
  intra-block chunker that carves individually oversized blocks;
  Phase 2 is a CFG cut-point search that balances cuts against a
  target size. Cuts are validated against the trap regions
  derived from `Code.compute_trap_contexts`.

**Typing & generation:**
- `jvm_typing.ml` + `.mli` — per-Var kind inference. Forward pass
  over blocks: `Let`-bound Vars take their expression's kind.
  Defaults to `K_obj`. Mirrors
  `js_of_ocaml/compiler/lib-wasm/typing.ml`.
- `jvm_generate.ml` + `.mli` — IR → JVM bytecode. Walks blocks in a
  DFS-derived order, maintains `Var.t → JVM local` + `Addr.t →
  Jvm.Code.label` maps, and emits bytecode via `Jvm.Code`. Block
  entries mark their label and pre-allocate param locals;
  terminators emit cont-driven parallel renames (load all args onto
  the JVM operand stack, store to params in reverse to avoid
  clobber). Convert-on-assign coerces between kinds at every
  `emit_store` and every branch-edge move. `Pushtrap` installs a
  JVM exception-table entry `start..end → handler` catching
  `CamlException`, and the handler prelude unwraps to the bound
  `exn_var`. Raises `Unsupported` on gaps (mostly uncommon C
  primitives); the driver turns those into runtime-throwing stubs.

**Driver & pretty-printers:**
- `compile.ml` + `.mli` — the compile driver. Reads the bytecode (or
  links multiple `.cmo` / `.cma` inputs), runs the CLOSUREREC /
  CLOSURE pre-scan to collect function-info metadata, builds a
  per-function IR (`parse_function`), runs eval/deadcode/typing,
  applies `Method_split.split` for anything that wouldn't fit the
  JVM 64 KB limit, emits via `jvm_generate`, and assembles class
  files. Also emits the globals-init prelude that populates
  `Main.GLOBALS` from the DATA section at method entry. Any IR
  failure (parse or generate) writes a runtime-throwing method
  body instead of aborting.
- `print_function` / `print_ir` — debug dumps for the `--print-
  function PC` and `--print-ir PC` CLI flags. Neither compiles
  output; both exit after printing.

**Instrumentation:**
- `debug` / `timer` — opt-in per-pass tracing. Toggle via
  `JAVA_OF_OCAML_DEBUG=times,times_detail,primitives,functions,
  ir_emit,ir_trace,ir_gen_trace,split,split_times,eval,deadcode,
  dbug` (comma-separated; any subset). `times_detail` adds
  per-phase sub-breakdowns inside `emit-main` / `emit-closures`
  via `Timer_bucket`; `split_times` adds per-phase breakdowns
  inside `Method_split.split` via its own `Stat` module.

### Runtime

- `runtime-java/` — Java sources for the runtime classes
  (`Block.java`, `Closure.java`, `PartialClosure.java`,
  `CamlException.java`, `Channel.java`, `Bytes.java`,
  `Compare.java`). `javac` compiles them at build time;
  `embed_class_bytes.ml` reads the resulting `.class` files and
  emits `runtime_bytes.ml` as the `java_of_ocaml_runtime_bytes`
  library; `jvm_runtime` re-exports the bindings. Editing the
  runtime means editing the Java sources — `javac` catches typos at
  build time.

### Tests

- `compiler/tests-compiler/` — ppx_expect tests, one file per topic
  (`arithmetic.ml`, `array_module.ml`, `bigarray_module.ml`,
  `branch_relaxation.ml`, `bytecode_smoke.ml`, `cmo_reader.ml`,
  `corecursion.ml`, `deadcode.ml`, `emission_snapshots.ml`,
  `ephemeron.ml`, `eval.ml`, `exceptions.ml`, `extensible.ml`,
  `file_io.ml`, `float_module.ml`, `functions.ml`, `gadts.ml`,
  `high_arity.ml`, `int64_module.ml`, `int_module.ml`,
  `java_ffi.ml`, `java_ffi_ppx.ml`, `lazy_.ml`, `linker.ml`,
  `lists.ml`, `method_size_limit.ml`, `method_split.ml`,
  `method_split_e2e.ml`, `modules.ml`, `mutex_cond.ml`,
  `number_strings.ml`, `obj_module.ml`, `primitive_as_value.ml`,
  `pure_fun.ml`, `records.ml`, `refs.ml`, `source_map.ml`,
  `stdlib_link.ml`, `strings.ml`, `sys_module.ml`,
  `tuples_records_arrays.ml`, `variants.ml`). Auto-discovered by
  `gen-rules/gen.ml` which generates `dune.inc`. Run `dune promote`
  after adding a new test file. `emission_snapshots.ml` pins `javap
  -c Main.class` output for representative programs.
- `compiler/tests-compiler/util/` — test helpers. Key functions:
  `compile_and_run s` (ocamlc → java_of_ocaml → java, captures
  stdout) and `compile_and_javap s` (same pipeline, then `javap -c
  Main.class`).
- `compiler/tests-java_of_ocaml/` — standalone executable tests with
  `.expected` output files. `byte` mode only; a `java` mode is
  aspirational pending a real dune plugin.
- `compiler/tests-full/` — library compilation tests; mostly
  placeholder.

### Docs

- `docs/ALIGNMENT.md` — index of remaining structural / API
  alignments with jsoo. The IR layer is resolved; follow-on passes
  (Flow, Deadcode, Inline, Closure_conversion, etc.) are tracked
  there. Add newly spotted items there rather than letting them
  slip.

## Kind-tracking model

The `Kind.kind` enum records what each value's runtime shape is;
`jvm_typing.infer` produces a per-Var mapping:

```ocaml
type kind =
  | K_int            (* primitive JVM [int] *)
  | K_string         (* JVM [java.lang.String] *)
  | K_float          (* primitive JVM [double] (2-wide) *)
  | K_block of kind list  (* [Block] with known field kinds *)
  | K_closure of closure_ref
  | K_obj            (* opaque — coerced on demand *)
```

`K_obj` is the universal carrier. Anything crossing a block edge, an
apply-method arg, or a capture field defaults to `K_obj`; downstream
uses unbox on demand in `Jvm_generate.emit_store` (which coerces
top-of-stack from the producing kind to the storing kind — boxing
int/float to `Integer` / `Double`, or checkcast + `intValue` /
`doubleValue` in reverse).

## JVM-specific considerations vs WASM

- JVM has a typed operand stack and structured method calls rather
  than WASM's linear memory + GC extension.
- JVM tail calls are not native — `APPTERM*` compiles to
  `invokevirtual` + `areturn` (no TCO, but the JIT often handles it).
- OCaml value representation maps to the JVM object model:
  - ints → `java.lang.Integer` (boxed when crossing into `Object`-
    typed args; primitive JVM `int` in local scope).
  - floats → `java.lang.Double` / primitive JVM `double`.
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
  primary architectural reference. `code_generation.ml`,
  `closure_conversion.ml`, `tail_call.ml`, `gc_target.ml`,
  `typing.ml` (the model for our `jvm_typing`), `generate.ml`
  (the model for our `jvm_generate`, especially the
  `convert-on-assign` idiom at line ~1920).
- **js_of_ocaml shared compiler lib** (`js_of_ocaml/compiler/lib/`)
  — `code.ml` (the model for our `code.ml`), `parse_bytecode.ml`
  (the model for our `parse_bytecode.ml`), `driver.ml`.
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

With the structural IR in place, the natural next layers are
optimisation passes on `Code.program → Code.program` (Flow /
Deadcode / Inline / Eval / Tailcall / Global_deadcode) and
separate-compilation inputs (`from_cmo` / `from_cma`). These are
tracked in [`docs/ALIGNMENT.md`](docs/ALIGNMENT.md). Add newly
spotted items there rather than letting them slip.
