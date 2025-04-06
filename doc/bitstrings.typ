#import "lib/setups.typ": setups
#show: setups

= Bitstrings for Bee

== Example: header parsing in C

Take the following eBPF C code
#footnote[
  Source: https://eunomia.dev/en/tutorials/41-xdp-tcpdump/.
  I inlined the `is_tcp` function for didactic purposes.
]
as an example:

```c
#define ETH_P_IP 0x0800

int main(struct xdp_md *packet) {
  // (1) Pointers to the packet data and its end
  void *data = (void *)(long)packet->data;
  void *data_end = (void *)(long)packet->data_end;

  // (2) Parse Ethernet header via an unsafe cast
  struct ethhdr *eth = data;

  // (3) Ensure Ethernet header is within bounds
  if ((void *)(eth + 1) > data_end)
    return XDP_PASS;

  // (4) Only handle IPv4 packets
  if (bpf_ntohs(eth->h_proto) != ETH_P_IP)
    return XDP_PASS;

  // (5) Parse IP header via an unsafe cast
  struct iphdr *ip = (struct iphdr *)(eth + 1);

  // (6) Ensure IP header is within bounds
  if ((void *)(ip + 1) > data_end)
    return XDP_PASS;

  // (7) Check if the protocol is TCP
  if (ip->protocol != IPPROTO_TCP)
    return XDP_PASS;

  ...
}
```

There are a lot of checks going on on pointers,
casts on data,
and early returns.
What happens is that a blob of binary data is available between  location `packet->data` and `packet->data_end`.
Piece-by-piece, this data is "parsed" into an ethernet header `eth`,
and an IP header `ip` (blocks 2 and 5).
We need to check the headers are "in bounds",
i.e. is the space between `data` and `data_end` is big enough to hold these headers (blocks 3 and 6)?
In between, we check if we have an IPv4 packet,
and the protocol used is TCP (blocks 4 and 7).
All-in-all, here we see quite some pointer juggling in C to get out the correct data and be sure it has the right size...

== Bitstrings and binaries

Instead of unsafe casts and pointer magic,
Erlang and its descendants Elixir and Gleam support _bitstrings_ and _binaries_.
#footnote[
  More information on https://www.erlang.org/doc/system/bit_syntax.html.
]
Bitstrings are just that: strings of single bits.
Binaries are bitstrings which length is divisible by 8,
i.e. a consecutive string of _bytes_.

In Erlang/Elixir/Gleam, we write binaries like `<<104, 101, 108, 108, 111>>`.
Here we see 5 bytes.
Using ASCII encoding this reads "hello".
This is not special per se, as this is the same as an array of unsigned bytes in C: `(*u8){104, 101, 108, 108, 111}`.
What ís special, is that Erlang/Elixir/Gleam can also _pattern match_ on bitstrings and binaries:
```koka
match binary_data {
  <<first_8_bits:8, next_2_bytes:16, rest:binary>> -> ...
    // do some calculations here and use the variables `first_8_bits`, `next_2_bytes`
    // the remaining binary data is bound to `rest`
  <<a:8, b:8>> -> ...
    // `binary_data` was not big enough, maybe it only holds 16 bits?
    // if that's the case, `a` and `b` are bound to both bytes
  _ -> ...
    // no match, do something else
}
```

The first pattern in this match sequence,
matches a substring of 8 bits, called `first_8_bits`;
followed by a substring of 16 bits, called `next_2_bytes`;
followed by a remaining _non zero length_ substring `rest`
which needs to be a binary (multiple of 8 bits).
The second pattern matches _exactly_ two substrings `a` and `b`,
both of 8 bits.
The last catch all pattern, matches anything.

== Example revisited: header parsing in Bee

Let's see how we can leverage pattern matching on bitstrings in TCP example.

=== Types

First of all, we need the following types for XDP packets:

```koka
struct xdp/packet
  data: binary
  metadata: binary
```
Ethernet headers:
#footnote[
  Based on https://docs.rs/network-types/latest/network_types/eth/index.html.
]

```koka
struct ethernet/header
  dst: binary //<6>
  src: binary //<6>
  kind: ethernet/header/kind

enum ethernet/header/kind
  Loop = 24576
  Ipv4 = 8
  Arp = 1544
  Ipv6 = 56710
  FibreChannel = 1673
  Infiniband = 5513
  LoopbackIeee8023 = 144
```

And for IP headers:
#footnote[
  Based on https://docs.rs/network-types/latest/network_types/ip/index.html.
]


```koka
struct ip/v4/header
  _omit: b8
  tos: b8
  tot-len: b16
  id: b16
  frag-off: b16
  ttl: b8
  proto: protocol // b8
  check: b16
  src-addr: b32
  dst-addr: b32

type ip/protocol
  // omitted
```

Here I left out the specification of IPv6 data and the IP protocol enum, which is quite long.

=== Header parsing

Now let us rewrite our C example into Bee, making use of our header types and pattern matching on binaries.

```koka
fun ethernet/header/parse(data: binary) -> option<(ethernet/header, binary)>
  match data
    <<dst:binary<6>, src:binary<6>, kind:16, rest:_>> ->
      Some((ethernet/Header(dst, src, kind), rest))
    _ -> None // No valid ethernet header

fun ip/v4/header/parse(data: binary) -> option<(ip/v4/header, binary)>
  match data
    <<_:8, tos:8, tot-len:16, id:16, frag-off:16, ttl:8,
      proto:8, check:16, src-addr:32, dst-addr:32, rest:_>> ->
        Some((ip/v4/Header(tos, tot-len, id, frag-off, ttl,
          proto, check, src-addr, dst-addr), rest))
    _ -> None // No valid Ipv4 header
```

Parsing a header now pattern matches pieces of the binary data and uses it to construct each header data type.
Note that we're _copying_ each 8, 16, or 32 bits here.
On success, it returns a tuple of the header data and the rest of the binary data.
On failure, it returns `None`.

The main function can now be written like this:
```koka
fun main(packet: xdp/packet)
  guard val Some(eth, rest) = ethernet/header/parse(packet.data) else xdp/Pass
  guard eth.proto == Ipv4 else xdp/Pass
  guard val Some(ip, rest) = ip/v4/header/parse(rest) else xdp/Pass
  guard ip.proto == Tcp else xdp/Pass
  ...
```

It calls our `parse` functions for both headers and pattern matches on the result.
In between, it checks if the protocols are indeed `Ipv4` and `Tcp`.

The `guard-val-else` syntax is sugar for the following ordinary pattern match:
#footnote[
  Based on Rust's syntax described in https://doc.rust-lang.org/rust-by-example/flow_control/if_let.html and https://doc.rust-lang.org/rust-by-example/flow_control/let_else.html.
]
```koka
  guard val p = e0 else e2; e1
==>
  match e0
    p -> e1
    _ -> e2
```
And `guard-else` is sugar for an `if-then-else`:
```koka
  guard e0 else e2; e1
==>
  if e0 then e1 else e2
```
Without any sugar, this example would look like this:
```koka
fun main(packet: xdp/packet)
  match ethernet/header/parse(packet.data)
    Some(eth, rest) -> if eth.proto == Ipv4
      then match ip/v4/header/parse(rest)
        Some(ip, rest) -> if ip.proto == Tcp
          then ...
          else xdp/Pass
        _ -> xdp/Pass
      else xdp/Pass
    _ -> xdp/Pass
```
which is barely readable...
#footnote[
  For the currious, this example in Haskell would look like:
  ```haskell
  main packet
    | Some (eth, rest) <- ethernet/header/parse packet.data,
      eth.proto == Ipv4,
      Some (ip, rest) <- ip/v4/header/parse rest,
      ip.proto == Tcp,
      = ...
    | otherwise = xdp/Pass
  ```
]

=== Optimalisation

Alternatively, because the compiler knows the exact size of the `ethernet/header` and the `ip/header` types, one can imagine writing above parser functions like:
```koka
fun ethernet/header/parse(data: binary) -> option<(ethernet/header, binary)>
  match data
    <<header:ethernet/header, rest:_>> -> Some((header, rest))
    _ -> None // No valid ethernet header

fun ip/v4/header/parse(data: binary) -> option<(ip/v4/header, binary)>
  match data
    <<header:ip/v4/header, rest:_>> -> Some((header, rest))
    _ -> None // No valid Ipv4 header
```
Here we can _reuse_ the underlying binary data in the same way our original C function does.
