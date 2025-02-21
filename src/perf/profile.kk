// @licence("Dual BSD/GPL")
module src/perf/profile

import ext/array

val task-comm-len = 16
val max-stack-depth = 128

alias stack-trace = array/unboxed<max-stack-depth,nat64>