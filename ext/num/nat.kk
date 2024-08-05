module ext/num/nat

pub import std/num/int32
pub import std/num/int64
import ext/unsafe

pub alias nat = int32

pub fun nat(i: int): nat
  i.nat32

pub alias nat8 = int8
pub alias nat16 = int16
pub alias nat32 = int32
pub alias nat64 = int64

//// Conversions ////

// int //

pub fun int/nat8(i: int): nat8
  i.int8

pub fun int/nat16(i: int): nat16
  i.int16

pub fun int/nat32(i: int): nat32
  i.int32

pub fun int/nat64(i: int): nat64
  i.int64

// nat16 //

pub fun nat16/nat32(i: int16): nat32
  i.int32

// nat32 //

pub fun nat32/split2(bs: nat32): (nat16, nat16)
  unsafe/cast(bs)

// nat64 //

pub extern nat64/nat32(n: nat64): nat32
  c inline "(uint32_t)(#1)"

pub fun nat64/split2(bs: nat64): (nat32, nat32)
  unsafe/cast(bs)


pub fun main()
  val x = 1.nat32.shl(16+3)
  val y = 1.nat32.shl(3)
  val z = x.or(y)
  println(z)
  val (a,b) = z.split2
  println(a.nat32)
  println(b.nat32)