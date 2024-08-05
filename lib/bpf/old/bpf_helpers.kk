module eBPF/bpflib/bpf_helpers

import std/num/int64
import std/num/int32
import eBPF/bpflib/bpf


/* long bpf_get_ns_current_pid_tgid(u64 dev, u64 ino, struct bpf_pidns_info *nsdata, u32 size)
    Description: Returns 0 on success, values for pid and tgid as
                 seen from the current namespace will be returned in nsdata.
                 Return 0 on success, or one of the following in case of
                 failure: -EINVAL if dev and inum supplied don't match dev_t
                           and inode number with nsfs of current task, or if
                           dev conversion to dev_t lost high bits.
                          -ENOENT if pidns does not exists for the current task. */
pub extern bpf_get_ns_current_pid_tgid (dev : int64, ino : int64, nsdata : ref<h,bpf_pidns_info>, size : int32) : int64 
  c inline "bpf_get_ns_current_pid_tgid(#1, #2, #3, #4)"

pub extern sizeof (n : a) : int32
  c inline "sizeof(#1)"

// Convert from big-endian to little-endian
pub extern bpf_htons (x : int32) : int32
  c inline "__builtin_bswap32(#1)"


