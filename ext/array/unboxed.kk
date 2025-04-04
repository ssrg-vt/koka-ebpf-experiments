module ext/array/unboxed

import ext/array/bytes
import ext/num/nat


// Immutable view into unboxed `a`s
// @repr(Value)
pub value type unboxed<a>
  Unboxed(slice: forall<h> slice<h,a>)

// Mutable slice of unboxed `a`s
// @repr(Value)
pub value type slice<h::H,a>
  Slice(buffer: buffer<h,a>, offset: nat, length: nat)

// Mutable buffer of unboxed `a`s
// @repr(Value)
pub value type buffer<h::H,a>
  Buffer(data: bytes/buffer<h>)


// fun at(xs: unboxed<a>, i: nat, ?at: (bytes, nat) -> a): a
//   xs.slice.buffer.at(xs.slice.offset + i)

// fun put(xs: unboxed<a>, i: nat, x: a, ?put: (bytes, nat, a) -> bytes): unboxed<a>
//   xs(slice = xs.slice.buffer.put(xs.slice.offset + i, x))