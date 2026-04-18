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

(* A method's CP indices are captured up-front so they can be interned
   BEFORE the constant pool is serialised. Code bytes are realised at the
   same time (triggering label resolution and any final CP additions). *)
type method_layout =
  { m : method_desc
  ; code_bytes : string
  ; name_idx : int
  ; desc_idx : int
  ; code_attr_idx : int
  }

let emit_method_info out (l : method_layout) =
  let code_len = String.length l.code_bytes in
  let entries = Code.exception_entries l.m.code in
  let n_entries = List.length entries in
  add_u2 out l.m.access_flags;
  add_u2 out l.name_idx;
  add_u2 out l.desc_idx;
  add_u2 out 1 (* one Code attribute *);
  add_u2 out l.code_attr_idx;
  let attr_len = 2 + 2 + 4 + code_len + 2 + (8 * n_entries) + 2 in
  add_u4 out attr_len;
  add_u2 out (Code.max_stack l.m.code);
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
  add_u2 out 0 (* nested attributes_count *)

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
    ~class_name
    ~super_name
    ~cp
    ~fields
    ~methods
    ~access_flags
  =
  let method_layouts =
    List.map
      (fun m ->
        let bytes = Code.contents m.code in
        { m
        ; code_bytes = bytes
        ; name_idx = Cp.utf8 cp m.name
        ; desc_idx = Cp.utf8 cp m.descriptor
        ; code_attr_idx = Cp.utf8 cp "Code"
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
  let this_class = Cp.class_ cp class_name in
  let super_class = Cp.class_ cp super_name in
  let out = Buffer.create 512 in
  add_u4 out 0xCAFEBABE;
  add_u2 out 0;
  add_u2 out 49 (* major_version = Java 5. Old-style type-inference
                   verification, so no StackMapTable needed. *);
  add_u2 out (Cp.count cp + 1);
  Buffer.add_string out (Cp.contents cp);
  add_u2 out access_flags;
  add_u2 out this_class;
  add_u2 out super_class;
  add_u2 out 0;
  add_u2 out (List.length fields);
  List.iter (emit_field_info out) field_layouts;
  add_u2 out (List.length methods);
  List.iter (emit_method_info out) method_layouts;
  add_u2 out 0;
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
