module ext/bits

import ext/unsafe
import ext/tuple

// @extern(C, "kk_bits8_t")
type bits8
// @extern(C, "kk_bits16_t")
type bits16
// @extern(C, "kk_bits32_t")
type bits32
// @extern(C, "kk_bits64_t")
type bits64

//// bits64 ////

pub fun bits64/split2(bs: bits64): (bits32, bits32)
  unsafe/cast(bs)

pub fun bits64/split4(bs: bits64): (bits16, bits16, bits16, bits16)
  unsafe/cast(bs)

// pub fun bits64/split8(bs: bits64): (bits8, bits8, bits8, bits8, bits8, bits8, bits8, bits8)
//   unsafe/cast(bs)

//// bits32 ////

pub fun bits32/split2(bs: bits32): (bits16, bits16)
  unsafe/cast(bs)

pub fun bits32/split4(bs: bits32): (bits8, bits8, bits8, bits8)
  unsafe/cast(bs)

//// bits 16 ////

pub fun bits16/split2(bs: bits16): (bits8, bits8)
  unsafe/cast(bs)


pub fun main()
  val x = 1.nat64.shl(35)
  val y = 1.nat64.shl(3)
  val z =