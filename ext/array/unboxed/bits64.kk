module ext/array/unboxed/bits64

import ext/array
import ext/bits
import ext/todo

pub fun new()
  todo

pub fun length(bs: bytes): todo nat
  bs.bytes/length / 8.nat

pub fun at(bs: bytes, i: nat): bits64
  todo

pub fun replace(bs: bytes, i: nat, x: bits64): bytes
  todo