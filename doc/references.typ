#set raw(syntaxes: ("assets/koka.sublime-syntax",))

#let always(x) = (y) => x
#let so = $=>$
#let verdicts(it) = {
  set enum(numbering: always($plus.circle$))
  set list(marker: $minus.circle$)
  it
}

= References in BeePL

== Preliminaries

What we'd like to translate, is a simple packet counter.
When written in eBPF C, it reads like:

```c
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

int counter = 0;

SEC("xdp")
int packet_count(void *ctx) {
    bpf_printk("%d", counter);
    counter++;
    return XDP_PASS;
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
```

Here, `packet_count` is the main runner which makes use of a global variable `counter`.
If I understand eBPF correctly, the following happens:

1. This module is loaded into the kernel once.
2. `packet_count` is called every time a packet arrives in the kernel.
3. eBPF bytecode only has the ability to allocate values on the stack, or call helper functions that do something with memory managed by the kernel (e.g. for maps).

Connor found out, that the global variable `counter` is actually transformed into a eBFP map, which is initialised on first load of the module.
Problem in a functional language like BeePL is the mutation of the `counter`,
which is not allowed in a pure functional setting.
Below two approaches to solve this.
Solution (1) is based on pure functional programming.
Solution (2) is a more pragmatic approach,
although when supported by an effect system quite elegant I think.

== 1. Using model-update (MU)

The first solution uses a _model-update_ approach.
#footnote[
  Derived from the _model-view-update_ approach used by systems like React and Elm.
]
_Conceptually_ we need three things:
+ Programmers need to specify an `init()` function.
  Upon loading a BeePL module into the kernel,
  the `init()` function should be called.
  This function returns some _initial state_.
+ Every time the runner function is called,
  it gets its usual arguments and also the _current state_.
+ When the runner ends,
  it should return its expected return value,
  as well as a (possibly updated) state.

Essentially, this encodes a pure state transforming function.
For above packet count example, it would look like this:
```koka
@license("GPL")
module packet-count

import lib/bpf
import lib/bpf/xdp

// Programmer needs to define the `State` type.
type State
  count: nat

// Called upon loading into the kernel.
// Only returns a `State`
fun init() -> State
  State(count: 0)

// Called every time a packet arrives in the kernel.
// Should take and return a `State`.
@section("xdp")
fun run(packet: xdp/packet, state: State) -> (xdp/Result, State)
  bpf/print("current count: " ++ state.count.show)
  // We conceptually return a tuple with:
  // - the asked (by the kernel) return value;
  // - _and_ an updated `State`.
  ( xdp/Pass, state.with(count = state.count + 1) )
```

Note that eBPF doesn't allow multiple return values (if I'm correct).
This is why I wrote we _conceptually_ need above feature list.
The compiler should transform reading and writing of the state to proper mutating calls.
This could be tricky.
Probably we would need to do something along these lines:

- Allocate a eBPF map with all state data on `init()`.
- Replace lookups in the state, with calls to map helper functions.
- Inject code at the end of every state transforming function that mutates the map.

#verdicts[

=== Advantages

  + Pure functions without effects:
  + #so simpler type system;
  + #so "easy" mental model.#footnote[See for example Elm, which is regarded "easy".]
  + Clear distinction between initialisation and running of code.


=== Disadvantages

  - Compiler should rewrite the state transformer to mutating map.
  - Explicitly think about the distinction between initialisation and running.
  - Needs the definition and creation of a `State` object.

]


== 2. Using global variables and effects

The second solution would be a mix of how ML (OCaml and StandardML) handle references,
and how Koka handles them.
In ML, one can define bindings in a file from top to bottom,
making use from previously defined bindings.
These bindings can be constants, functions, and also references.
So, functions can use bindings to references and mutate them.
Koka adds effects into the mix with support for regions,
but doesn't allow for global variables.

We could combine both approaches. Say
- we allow for the definition of global values;
- these could happen to be references;
- all references are allocated in the `global` region.
- still annotate functions that read/write/allocate with the proper effects.

It would look like this:
```koka
@license("GPL")
module packet-count

import lib/bpf
import lib/bpf/xdp

// We create a value with a global scope.
// in this case it happens to be a reference
val count = ref(0)
// (Could also be written `var count := 0`, which is equivalent.)
// This data is initialised in an eBPF map, in the same way the C version does.

@section("xdp")
// Functions are still annotated with the effects they need/produce.
// In this case `read`ing and `write`ng to the `global` heap.
fun run(p: xdp/packet) -> < read<global>, write<global> > xdp/Result
  // We can access the global name `count` here...
  bpf/print("current count: " ++ count.show)
  // ...and mutate its contents.
  count := count + 1
  xdp/Pass
```

#verdicts[

=== Advantages

  + Functions are annotated with effects:
  + #so functions which are pure, don't have any effects;
  + #so functions having side effects, need to mention them in the type.
  + No need for a `State` type.
  + Mental model is the same as for C programs, but safer (because of effect signatures).
  + Get rid of _heap variables_.
    There is only one place to allocate references: in the `global` heap.
  + #so Makes reasoning about heap regions easier.

=== Disadvantages

  - No pure functions any more (but that wasn't the plan initially).
  - Still need for effect signatures.
  - Initialisation and running of code are mingled (but this also is the case for programs in C).
  - Compiler should rewrite global reference access to eBPF map access
    and global constant usage to inlining.

]
