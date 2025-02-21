module ext/bits/bits32

import ext/unsafe
import ext/bits/bits8
import ext/bits/bits16


// @extern(C, "kk_bits32_t")
pub type bits32

pub fun bits32/split2(bs: bits32): (bits16, bits16)
  unsafe/cast(bs)

pub fun bits32/split4(bs: bits32): (bits8, bits8, bits8, bits8)
  unsafe/cast(bs)
