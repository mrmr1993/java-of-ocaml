open Jvm_bin
module Cp = Jvm_constant_pool
module Code = Jvm_code

type method_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  ; code : Code.t
  }

type field_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  }

exception Method_too_large of
    { class_name : string
    ; method_name : string
    ; size : int
    }

(* Maximum byte length of a JVM [Code] attribute's code array (u4 field,
   but JVMS §4.7.3 caps it at 65535). *)
let code_size_limit = 65535

(* A method's CP indices are captured up-front so they can be interned
   BEFORE the constant pool is serialised. Code bytes are realised at the
   same time (triggering label resolution and any final CP additions). *)
type method_layout =
  { m : method_desc
  ; code_bytes : string
  ; name_idx : int
  ; desc_idx : int
  ; code_attr_idx : int
  ; line_entries : (int * int) list
  ; line_number_table_idx : int
        (* CP utf8 index for "LineNumberTable", or 0 if no entries. *)
  }

let emit_method_info out (l : method_layout) =
  let code_len = String.length l.code_bytes in
  let entries = Code.exception_entries l.m.code in
  let n_entries = List.length entries in
  let n_lines = List.length l.line_entries in
  let nested_attrs = if n_lines > 0 then 1 else 0 in
  let lnt_attr_len = 2 + (4 * n_lines) in
  let lnt_total = if n_lines > 0 then 6 + lnt_attr_len else 0 in
  add_u2 out l.m.access_flags;
  add_u2 out l.name_idx;
  add_u2 out l.desc_idx;
  add_u2 out 1 (* one Code attribute *);
  add_u2 out l.code_attr_idx;
  let attr_len = 2 + 2 + 4 + code_len + 2 + (8 * n_entries) + 2 + lnt_total in
  add_u4 out attr_len;
  (* The forward-walk tracker under-declares around spill/reload
     scaffolding and join-block prologues that re-push acc after
     a branch already popped it. Large large-scale methods have
     seen the real peak run 100+ slots above the tracked value,
     so we can't afford the tiny [+8] margin that was enough for
     the test corpus. Take the maximum of a scaled overestimate
     (covers bodies with parallel-move edges whose peak equals
     the edge's arg count) and a floor that covers the constant-
     margin case. [max_locals] is a sound upper bound since the
     stack holds at most as many values as the method references
     at once, and that in turn is bounded by the local count plus
     a handful of temps. *)
  let tracked = Code.max_stack l.m.code in
  let locals = Code.max_locals l.m.code in
  let generous = max (tracked + 64) (locals + 64) in
  add_u2 out (min 65535 generous);
  add_u2 out (Code.max_locals l.m.code);
  add_u4 out code_len;
  Buffer.add_string out l.code_bytes;
  add_u2 out n_entries;
  List.iter
    (fun (start_pc, end_pc, handler_pc, catch_type) ->
      add_u2 out start_pc;
      add_u2 out end_pc;
      add_u2 out handler_pc;
      add_u2 out catch_type)
    entries;
  add_u2 out nested_attrs;
  if n_lines > 0
  then (
    add_u2 out l.line_number_table_idx;
    add_u4 out lnt_attr_len;
    add_u2 out n_lines;
    List.iter
      (fun (jvm_pc, line) ->
        add_u2 out (jvm_pc land 0xffff);
        add_u2 out (line land 0xffff))
      l.line_entries)

type field_layout =
  { f : field_desc
  ; f_name_idx : int
  ; f_desc_idx : int
  }

let emit_field_info out (l : field_layout) =
  add_u2 out l.f.access_flags;
  add_u2 out l.f_name_idx;
  add_u2 out l.f_desc_idx;
  add_u2 out 0

let assemble_class
    ?source_file
    ~class_name
    ~super_name
    ~cp
    ~fields
    ~methods
    ~access_flags
    ()
  =
  let method_layouts =
    List.map
      (fun m ->
        let bytes =
          try Code.contents m.code with
          | Failure msg ->
            failwith
              (Printf.sprintf "%s (in method %s.%s)" msg class_name m.name)
        in
        let size = String.length bytes in
        if size > code_size_limit
        then
          raise
            (Method_too_large
               { class_name; method_name = m.name; size });
        let line_entries = Code.line_entries m.code in
        let line_number_table_idx =
          if line_entries = [] then 0 else Cp.utf8 cp "LineNumberTable"
        in
        { m
        ; code_bytes = bytes
        ; name_idx = Cp.utf8 cp m.name
        ; desc_idx = Cp.utf8 cp m.descriptor
        ; code_attr_idx = Cp.utf8 cp "Code"
        ; line_entries
        ; line_number_table_idx
        })
      methods
  in
  let field_layouts =
    List.map
      (fun f ->
        { f
        ; f_name_idx = Cp.utf8 cp f.name
        ; f_desc_idx = Cp.utf8 cp f.descriptor
        })
      fields
  in
  let source_file_attr =
    match source_file with
    | None -> None
    | Some name ->
      let attr_idx = Cp.utf8 cp "SourceFile" in
      let name_idx = Cp.utf8 cp name in
      Some (attr_idx, name_idx)
  in
  let class_attrs_count = if source_file_attr = None then 0 else 1 in
  let this_class = Cp.class_ cp class_name in
  let super_class = Cp.class_ cp super_name in
  (* The class-file [constant_pool_count] is a u2: the pool can
     hold at most 65534 usable entries (indices 1..65534; index 0
     is reserved). If we overflow, [add_u2] silently truncates and
     the resulting class file is malformed — the JVM rejects it
     with a cryptic "Invalid this class index N" from whatever
     garbage ends up at the header position. Surface this as a
     clear compiler error instead. *)
  let cp_entries = Cp.count cp in
  if cp_entries + 1 > 0xFFFF
  then
    failwith
      (Printf.sprintf
         "jvm: class %s constant pool has %d entries, exceeds u2 \
          limit (65534). Class needs to be split."
         class_name
         cp_entries);
  let out = Buffer.create 512 in
  add_u4 out 0xCAFEBABE;
  add_u2 out 0;
  add_u2 out 49 (* major_version = Java 5. Old-style type-inference
                   verification, so no StackMapTable needed. *);
  add_u2 out (cp_entries + 1);
  Buffer.add_string out (Cp.contents cp);
  add_u2 out access_flags;
  add_u2 out this_class;
  add_u2 out super_class;
  add_u2 out 0;
  add_u2 out (List.length fields);
  List.iter (emit_field_info out) field_layouts;
  add_u2 out (List.length methods);
  List.iter (emit_method_info out) method_layouts;
  add_u2 out class_attrs_count;
  (match source_file_attr with
   | None -> ()
   | Some (attr_idx, name_idx) ->
     add_u2 out attr_idx;
     add_u4 out 2;
     add_u2 out name_idx);
  Buffer.contents out

let assemble_main_class build =
  let cp = Cp.create () in
  let main_code = Code.create cp in
  build cp main_code;
  assemble_class
    ~class_name:"Main"
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:[]
    ~methods:
      [ { name = "main"
        ; descriptor = "([Ljava/lang/String;)V"
        ; access_flags = 0x0009
        ; code = main_code
        }
      ]
    ~access_flags:0x0021
    ()
