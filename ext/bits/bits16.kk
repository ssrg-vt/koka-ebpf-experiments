module ext/bits/bits16

import ext/unsafe
import ext/bits/bits8



// @extern(C, "kk_bits16_t")
pub type bits16

pub fun split2(bs: bits16): (bits8, bits8)
  unsafe/cast(bs)
