module ext/bytes

import ext/num/nat

pub alias byte = nat8
pub alias bytes = vector<byte>

pub fun size(b: bytes): nat
  0.nat