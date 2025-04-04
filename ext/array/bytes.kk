module ext/array/bytes

import ext/num/nat
import ext/bits
import ext/todo

// Immutable view into bytes
// @repr(Value)
pub type bytes
  Bytes(slice: forall<h> slice<h>)

pub fun empty()
  Bytes(Slice(Buffer(vector()), 0.nat, 0.nat))

// Mutable slice of bytes
// @repr(Value)
pub type slice<h::H>
  Slice(buffer: buffer<h>, offset: nat, length: nat)

// Mutable buffer of bytes
// @repr(Value)
pub type buffer<h::H>
  // Buffer(data: ref<h,vector<byte>>)
  Buffer(data: vector<byte>)
