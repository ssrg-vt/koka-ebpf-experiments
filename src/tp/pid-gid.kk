// @licence("Dual BSD/GPL")
module src/tp/pid-gid

import lib/bpf
import lib/bpf/process

val my/pid = 0.nat32

// @section("tp/syscalls/sys_enter_write")
// FIXME: type of
fun run(c: a)
  val pid = bpf/process/pid()
  if pid == my/pid then
    bpf/print("BPF triggered from PID" ++ pid.show)

  0.int32
