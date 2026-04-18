module Cp = Jvm_constant_pool
module Code = Jvm_code
open Jvm_class_file

let apply_descriptor n =
  let buf = Buffer.create 16 in
  Buffer.add_char buf '(';
  for _ = 1 to n do
    Buffer.add_string buf "Ljava/lang/Object;"
  done;
  Buffer.add_string buf ")Ljava/lang/Object;";
  Buffer.contents buf

let max_supported_arity = 7

let closure_class_bytes () =
  let cp = Cp.create () in
  let ctor = Code.create cp in
  Code.set_min_locals ctor 1;
  Code.aload ctor 0;
  Code.invokespecial
    ctor
    ~class_:"java/lang/Object"
    ~method_:"<init>"
    ~descriptor:"()V";
  Code.return_void ctor;
  let arity_body = Code.create cp in
  Code.set_min_locals arity_body 1;
  Code.ldc_int arity_body 0;
  Code.ireturn arity_body;
  let under_body = Code.create cp in
  Code.set_min_locals under_body 3;
  Code.aload under_body 0;
  Code.invokevirtual
    under_body
    ~class_:"Closure"
    ~method_:"arity"
    ~descriptor:"()I";
  Code.iload under_body 1;
  let l_throw = Code.fresh_label under_body in
  Code.if_icmple under_body l_throw;
  Code.new_ under_body "PartialClosure";
  Code.dup under_body;
  Code.aload under_body 0;
  Code.aload under_body 2;
  Code.aload under_body 0;
  Code.invokevirtual
    under_body
    ~class_:"Closure"
    ~method_:"arity"
    ~descriptor:"()I";
  Code.invokespecial
    under_body
    ~class_:"PartialClosure"
    ~method_:"<init>"
    ~descriptor:"(LClosure;[Ljava/lang/Object;I)V";
  Code.areturn under_body;
  Code.mark_label under_body l_throw;
  Code.new_ under_body "java/lang/RuntimeException";
  Code.dup under_body;
  Code.ldc_string under_body "closure arity mismatch";
  Code.invokespecial
    under_body
    ~class_:"java/lang/RuntimeException"
    ~method_:"<init>"
    ~descriptor:"(Ljava/lang/String;)V";
  Code.athrow under_body;
  let make_apply_stub n =
    let body = Code.create cp in
    Code.set_min_locals body (1 + n);
    Code.ldc_int body n;
    Code.anewarray body "java/lang/Object";
    for k = 0 to n - 1 do
      Code.dup body;
      Code.ldc_int body k;
      Code.aload body (1 + k);
      Code.aastore body
    done;
    let arr_local = 1 + n in
    Code.astore body arr_local;
    Code.aload body 0;
    Code.ldc_int body n;
    Code.aload body arr_local;
    Code.invokevirtual
      body
      ~class_:"Closure"
      ~method_:"under"
      ~descriptor:"(I[Ljava/lang/Object;)Ljava/lang/Object;";
    Code.areturn body;
    { name = Printf.sprintf "apply%d" n
    ; descriptor = apply_descriptor n
    ; access_flags = 0x0001
    ; code = body
    }
  in
  let applies =
    let rec loop n =
      if n > max_supported_arity then [] else make_apply_stub n :: loop (n + 1)
    in
    loop 1
  in
  assemble_class
    ~class_name:"Closure"
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:[]
    ~methods:
      ({ name = "<init>"
       ; descriptor = "()V"
       ; access_flags = 0x0001
       ; code = ctor
       }
      :: { name = "arity"
         ; descriptor = "()I"
         ; access_flags = 0x0001
         ; code = arity_body
         }
      :: { name = "under"
         ; descriptor = "(I[Ljava/lang/Object;)Ljava/lang/Object;"
         ; access_flags = 0x0001
         ; code = under_body
         }
      :: applies)
    ~access_flags:0x0021

let partial_closure_class_bytes () =
  let cp = Cp.create () in
  let ctor = Code.create cp in
  Code.set_min_locals ctor 4;
  Code.aload ctor 0;
  Code.invokespecial
    ctor
    ~class_:"Closure"
    ~method_:"<init>"
    ~descriptor:"()V";
  Code.aload ctor 0;
  Code.aload ctor 1;
  Code.putfield ctor ~class_:"PartialClosure" ~field:"target" ~descriptor:"LClosure;";
  Code.aload ctor 0;
  Code.aload ctor 2;
  Code.putfield
    ctor
    ~class_:"PartialClosure"
    ~field:"captured"
    ~descriptor:"[Ljava/lang/Object;";
  Code.aload ctor 0;
  Code.iload ctor 3;
  Code.putfield ctor ~class_:"PartialClosure" ~field:"targetArity" ~descriptor:"I";
  Code.return_void ctor;
  let arity_body = Code.create cp in
  Code.set_min_locals arity_body 1;
  Code.aload arity_body 0;
  Code.getfield arity_body ~class_:"PartialClosure" ~field:"targetArity" ~descriptor:"I";
  Code.aload arity_body 0;
  Code.getfield
    arity_body
    ~class_:"PartialClosure"
    ~field:"captured"
    ~descriptor:"[Ljava/lang/Object;";
  Code.arraylength arity_body;
  Code.isub arity_body;
  Code.ireturn arity_body;
  let dispatch_body = Code.create cp in
  Code.set_min_locals dispatch_body 3;
  Code.aload dispatch_body 1;
  Code.arraylength dispatch_body;
  Code.istore dispatch_body 2;
  let l_throw = Code.fresh_label dispatch_body in
  for k = 1 to max_supported_arity do
    let l_next = Code.fresh_label dispatch_body in
    Code.iload dispatch_body 2;
    Code.ldc_int dispatch_body k;
    Code.if_icmpne dispatch_body l_next;
    Code.aload dispatch_body 0;
    Code.getfield
      dispatch_body
      ~class_:"PartialClosure"
      ~field:"target"
      ~descriptor:"LClosure;";
    for i = 0 to k - 1 do
      Code.aload dispatch_body 1;
      Code.ldc_int dispatch_body i;
      Code.aaload dispatch_body
    done;
    Code.invokevirtual
      dispatch_body
      ~class_:"Closure"
      ~method_:(Printf.sprintf "apply%d" k)
      ~descriptor:(apply_descriptor k);
    Code.areturn dispatch_body;
    Code.mark_label dispatch_body l_next
  done;
  Code.mark_label dispatch_body l_throw;
  Code.new_ dispatch_body "java/lang/RuntimeException";
  Code.dup dispatch_body;
  Code.ldc_string dispatch_body "unsupported partial-closure arity";
  Code.invokespecial
    dispatch_body
    ~class_:"java/lang/RuntimeException"
    ~method_:"<init>"
    ~descriptor:"(Ljava/lang/String;)V";
  Code.athrow dispatch_body;
  let make_apply_impl n =
    let body = Code.create cp in
    Code.set_min_locals body (1 + n);
    let cap_len_local = 1 + n in
    let total_local = 2 + n in
    let combined_local = 3 + n in
    Code.set_min_locals body (combined_local + 1);
    Code.aload body 0;
    Code.getfield
      body
      ~class_:"PartialClosure"
      ~field:"captured"
      ~descriptor:"[Ljava/lang/Object;";
    Code.arraylength body;
    Code.istore body cap_len_local;
    Code.iload body cap_len_local;
    Code.ldc_int body n;
    Code.iadd body;
    Code.istore body total_local;
    Code.iload body total_local;
    Code.anewarray body "java/lang/Object";
    Code.astore body combined_local;
    Code.aload body 0;
    Code.getfield
      body
      ~class_:"PartialClosure"
      ~field:"captured"
      ~descriptor:"[Ljava/lang/Object;";
    Code.ldc_int body 0;
    Code.aload body combined_local;
    Code.ldc_int body 0;
    Code.iload body cap_len_local;
    Code.invokestatic
      body
      ~class_:"java/lang/System"
      ~method_:"arraycopy"
      ~descriptor:"(Ljava/lang/Object;ILjava/lang/Object;II)V";
    for k = 0 to n - 1 do
      Code.aload body combined_local;
      Code.iload body cap_len_local;
      Code.ldc_int body k;
      Code.iadd body;
      Code.aload body (1 + k);
      Code.aastore body
    done;
    let l_saturated = Code.fresh_label body in
    Code.iload body total_local;
    Code.aload body 0;
    Code.getfield body ~class_:"PartialClosure" ~field:"targetArity" ~descriptor:"I";
    Code.if_icmpge body l_saturated;
    Code.new_ body "PartialClosure";
    Code.dup body;
    Code.aload body 0;
    Code.getfield body ~class_:"PartialClosure" ~field:"target" ~descriptor:"LClosure;";
    Code.aload body combined_local;
    Code.aload body 0;
    Code.getfield body ~class_:"PartialClosure" ~field:"targetArity" ~descriptor:"I";
    Code.invokespecial
      body
      ~class_:"PartialClosure"
      ~method_:"<init>"
      ~descriptor:"(LClosure;[Ljava/lang/Object;I)V";
    Code.areturn body;
    Code.mark_label body l_saturated;
    Code.aload body 0;
    Code.aload body combined_local;
    Code.invokevirtual
      body
      ~class_:"PartialClosure"
      ~method_:"dispatchSaturated"
      ~descriptor:"([Ljava/lang/Object;)Ljava/lang/Object;";
    Code.areturn body;
    { name = Printf.sprintf "apply%d" n
    ; descriptor = apply_descriptor n
    ; access_flags = 0x0001
    ; code = body
    }
  in
  let applies =
    let rec loop n =
      if n > max_supported_arity then [] else make_apply_impl n :: loop (n + 1)
    in
    loop 1
  in
  assemble_class
    ~class_name:"PartialClosure"
    ~super_name:"Closure"
    ~cp
    ~fields:
      [ { name = "target"
        ; descriptor = "LClosure;"
        ; access_flags = 0x0011
        }
      ; { name = "captured"
        ; descriptor = "[Ljava/lang/Object;"
        ; access_flags = 0x0011
        }
      ; { name = "targetArity"
        ; descriptor = "I"
        ; access_flags = 0x0011
        }
      ]
    ~methods:
      ({ name = "<init>"
       ; descriptor = "(LClosure;[Ljava/lang/Object;I)V"
       ; access_flags = 0x0001
       ; code = ctor
       }
      :: { name = "arity"
         ; descriptor = "()I"
         ; access_flags = 0x0001
         ; code = arity_body
         }
      :: { name = "dispatchSaturated"
         ; descriptor = "([Ljava/lang/Object;)Ljava/lang/Object;"
         ; access_flags = 0x0001
         ; code = dispatch_body
         }
      :: applies)
    ~access_flags:0x0031

let block_class_bytes () =
  let cp = Cp.create () in
  let code = Code.create cp in
  Code.set_min_locals code 3;
  Code.aload code 0;
  Code.invokespecial
    code
    ~class_:"java/lang/Object"
    ~method_:"<init>"
    ~descriptor:"()V";
  Code.aload code 0;
  Code.iload code 1;
  Code.putfield code ~class_:"Block" ~field:"tag" ~descriptor:"I";
  Code.aload code 0;
  Code.aload code 2;
  Code.putfield
    code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  Code.return_void code;
  assemble_class
    ~class_name:"Block"
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:
      [ { name = "tag"
        ; descriptor = "I"
        ; access_flags = 0x0011
        }
      ; { name = "fields"
        ; descriptor = "[Ljava/lang/Object;"
        ; access_flags = 0x0011
        }
      ]
    ~methods:
      [ { name = "<init>"
        ; descriptor = "(I[Ljava/lang/Object;)V"
        ; access_flags = 0x0001
        ; code
        }
      ]
    ~access_flags:0x0031

let camlexception_class_bytes () =
  let cp = Cp.create () in
  let code = Code.create cp in
  Code.set_min_locals code 2;
  Code.aload code 0;
  Code.invokespecial
    code
    ~class_:"java/lang/RuntimeException"
    ~method_:"<init>"
    ~descriptor:"()V";
  Code.aload code 0;
  Code.aload code 1;
  Code.putfield
    code
    ~class_:"CamlException"
    ~field:"value"
    ~descriptor:"Ljava/lang/Object;";
  Code.return_void code;
  assemble_class
    ~class_name:"CamlException"
    ~super_name:"java/lang/RuntimeException"
    ~cp
    ~fields:
      [ { name = "value"
        ; descriptor = "Ljava/lang/Object;"
        ; access_flags = 0x0011
        }
      ]
    ~methods:
      [ { name = "<init>"
        ; descriptor = "(Ljava/lang/Object;)V"
        ; access_flags = 0x0001
        ; code
        }
      ]
    ~access_flags:0x0031
