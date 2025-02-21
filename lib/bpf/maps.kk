import ext/bits

type array<a>

extern array/new(max-entries: bits32, flags: bits32): array<a>
  c inline "struct { __uint(type, BPF_MAP_TYPE_PERCPU_ARRAY); __uint(max_entries, #1); __type(key, __u32); __type(value, struct task_info); } task_info_buf SEC(".maps"); "


/*
    pub const fn with_max_entries(max_entries: u32, flags: u32) -> Array<T> {
        Array {
            def: UnsafeCell::new(bpf_map_def {
                type_: BPF_MAP_TYPE_ARRAY,
                key_size: mem::size_of::<u32>() as u32,
                value_size: mem::size_of::<T>() as u32,
                max_entries,
                map_flags: flags,
                id: 0,
                pinning: PinningType::None as u32,
            }),
            _t: PhantomData,
        }
    }

*/