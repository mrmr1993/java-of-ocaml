type +'a t
type +'a meth
type +'a static_meth
type +'a field
type +'a readonly_field
type +'a static_field
type +'a constr
type void
type java_string = string
type 'a java_array

module Unsafe = struct
  (* Reflective fallbacks. The primitive names target the static
     helpers on the [JavaFFI] runtime class, which do method-name
     + argument-type lookup on [obj.getClass()] and dispatch via
     [java.lang.reflect]. See runtime-java/JavaFFI.java. *)
  external meth_call : 'a t -> string -> Obj.t array -> 'b
    = "java:static:JavaFFI:callVirtual:(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;"

  external static_meth_call : string -> string -> Obj.t array -> 'b
    = "java:static:JavaFFI:callStatic:(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;"

  external new_obj : string -> Obj.t array -> 'a t
    = "java:static:JavaFFI:newInstance:(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;"

  external get : 'a t -> string -> 'b
    = "java:static:JavaFFI:getField:(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;"

  external set : 'a t -> string -> 'b -> unit
    = "java:static:JavaFFI:setField:(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V"

  external get_static : string -> string -> 'a
    = "java:static:JavaFFI:getStaticField:(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;"

  external set_static : string -> string -> 'a -> unit
    = "java:static:JavaFFI:setStaticField:(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V"

  external instanceof_by_name : 'a t -> string -> bool
    = "java:static:JavaFFI:instanceOf:(Ljava/lang/Object;Ljava/lang/String;)Z"

  let instanceof obj class_name = instanceof_by_name obj class_name

  external checkcast : 'a t -> 'b t = "%identity"

  external inject : 'a -> Obj.t = "%identity"
end
