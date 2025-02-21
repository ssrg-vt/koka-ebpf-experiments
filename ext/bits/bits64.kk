module ext/bits/bits64

import ext/unsafe
import ext/bits/bits8
import ext/bits/bits16
import ext/bits/bits32

// @extern(C, "kk_bits64_t")
pub type bits64

pub fun bits64/split2(bs: bits64): (bits32, bits32)
  unsafe/cast(bs)

pub fun bits64/split4(bs: bits64): (bits16, bits16, bits16, bits16)
  unsafe/cast(bs)

// pub fun bits64/split8(bs: bits64): (bits8, bits8, bits8, bits8, bits8, bits8, bits8, bits8)
//   unsafe/cast(bs)
