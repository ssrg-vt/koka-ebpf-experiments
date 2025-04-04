// @licence("Dual BSD/GPL")
module src/tp/pid-gid

import ext/fun

import lib/bpf
import lib/bpf/process

val my/pid = 0.nat32

// @section("tp/syscalls/sys_enter_write")
// FIXME: implementation of context type
fun run(c: a)
  val pid = bpf/process/pid()
  with guard(pid == my/pid) {()}

  bpf/print("BPF triggered from PID" ++ pid.show)
