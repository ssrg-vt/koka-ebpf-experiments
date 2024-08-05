module lib/bpf/process

import ext/num/nat
import lib/bpf
import lib/bpf/bindings

// fun command(): result<[u8; TASK_COMM_LEN], c_long>
//     bpf_get_current_comm()

pub fun pid(): kernel nat32
  bpf/bindings/get-current-pid-tgid().nat32

pub fun tgid(): kernel nat32
  bpf/bindings/get-current-pid-tgid().shr(32).nat32

pub fun uid(): kernel nat32
  bpf/bindings/get-current-uid-gid().nat32

pub fun gid(): kernel nat32
  bpf/bindings/get-current-uid-gid().shr(32).nat32
