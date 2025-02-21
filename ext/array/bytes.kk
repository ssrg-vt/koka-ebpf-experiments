module ext/array/bytes

import ext/num/nat
import ext/bits

import ext/todo

// Immutable view into bytes
// @repr(Value)
pub value type bytes
  Bytes(slice: forall<h> slice<h>)

// Mutable slice of bytes
// @repr(Value)
pub value type slice<h::H>
  Slice(buffer: buffer<h>, offset: nat, length: nat)

// Mutable buffer of bytes
// @repr(Value)
pub value type buffer<h::H>
  Buffer(data: ref<h,vector<byte>>)
