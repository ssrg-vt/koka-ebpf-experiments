module ext/array

import ext/num/nat
pub import ext/array/bytes
// pub import ext/array/unboxed/...

// Immutable view into boxed `a`s
// @repr(Value)
value type array<a>
  Array(slice: forall<h> slice<h,a>)

// Mutable slice of boxed `a`s
// @repr(Value)
value type slice<h::H,a>
  Slice(buffer: buffer<h,a>, offset: nat, length: nat)

// Mutable buffer of boxed `a`s
// @repr(Value)
value type buffer<h::H,a>
  Buffer(data: ref<h,vector<a>>)
