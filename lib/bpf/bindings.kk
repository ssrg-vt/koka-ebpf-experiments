module lib/bpf/bindings

import ext/num/nat

pub import lib/bpf/bindings/data


/*
u64 bpf_get_current_uid_gid(void)

  Description
    Get the current uid and gid.

  Return A 64-bit integer containing the current GID and
    UID, and created as such: current_gid << 32 |
    current_uid.
*/
pub extern get-current-uid-gid(): nat64
  c inline "bpf_get_current_uid_gid()"

/*
u64 bpf_get_current_pid_tgid(void)

  Description
    Get the current pid and tgid.

  Return A 64-bit integer containing the current tgid and
    pid, and created as such: current_task->tgid << 32
    | current_task->pid.
*/
pub extern get-current-pid-tgid (): nat64
  c inline "bpf_get_current_pid_tgid()"

/*
long bpf_get_ns_current_pid_tgid(u64 dev, u64 ino, struct
bpf_pidns_info *nsdata, u32 size)

  Description
    Returns 0 on success, values for pid and tgid as
    seen from the current namespace will be returned in
    nsdata.

  Return 0 on success, or one of the following in case of
    failure:

    -EINVAL if dev and inum supplied don't match dev_t
    and inode number with nsfs of current task, or if
    dev conversion to dev_t lost high bits.

    -ENOENT if pidns does not exists for the current
    task.
*/
// extern get-ns-current-pid-tgid(dev: nat64, ino: nat64, nsdata: pidns-info, size: nat32): int
//   c inline "bpf_get_ns_current_pid_tgid(#1, #2, &#3, #4)"