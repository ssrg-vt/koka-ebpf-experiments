module ext/num/nat

import std/num/int32
import std/num/int64

pub alias nat = int32

pub fun nat(i: int): nat
  i.nat32

pub alias nat8 = int8
pub alias nat16 = int16
pub alias nat32 = int32
pub alias nat64 = int64

pub fun nat8(i: int): nat8
  i.int8

pub fun nat16(i: int): nat16
  i.int16

pub fun nat32(i: int): nat32
  i.int32

pub fun nat64(i: int): nat64
  i.int64