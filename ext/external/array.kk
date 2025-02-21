module ext/external/array

import ext/num/nat
import ext/external/ref

// Immutable view into unboxed `a`s
// @repr(Value)
value type array<s::S,a>
  Array(slice: forall<h> slice<s,h,a>)

// Mutable slice of unboxed `a`s
// @repr(Value)
value type slice<s::S,h::H,a>
  Slice(buffer: buffer<s,h,a>, offset: nat, length: nat)

// Mutable buffer of unboxed `a`s
// @repr(Value)
value type buffer<s::S,h::H,a>
  Buffer(data: external/ref/ref<h,vector<a>>)
