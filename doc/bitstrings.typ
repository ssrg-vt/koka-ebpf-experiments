#import "lib/helpers.typ": *
#import "lib/commands.typ": *
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
  dst: binary<6>
  src: binary<6>
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
    <<dst:binary<6>, src:binary<6>, kind:b16, rest:_>> ->
      Some((ethernet/Header(dst, src, kind), rest))
    _ -> None // No valid ethernet header

fun ip/v4/header/parse(data: binary) -> option<(ip/v4/header, binary)>
  match data
    <<_:b8, tos:b8, tot-len:b16, id:b16, frag-off:b16, ttl:b8,
      proto:b8, check:b16, src-addr:b32, dst-addr:b32, rest:_>> ->
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
  if val Some(eth, rest) = ethernet/header/parse(packet.data) else xdp/Pass
  if eth.proto == Ipv4 else xdp/Pass
  if val Some(ip, rest) = ip/v4/header/parse(rest) else xdp/Pass
  if ip.proto == Tcp else xdp/Pass
  ...
```

It calls our `parse` functions for both headers and pattern matches on the result.
In between, it checks if the protocols are indeed `Ipv4` and `Tcp`.

The `if-val-else` syntax is sugar for the following ordinary pattern match:
#footnote[
  Based on Rust's syntax described in https://doc.rust-lang.org/rust-by-example/flow_control/if_let.html and https://doc.rust-lang.org/rust-by-example/flow_control/let_else.html.
]
```koka
  if val p = e0 else e2; e1
==>
  match e0
    p -> e1
    _ -> e2
```
And `if-else` is sugar for an `if-then-else`:
```koka
  if e0 else e2; e1
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

Alternatively, because the compiler knows the exact size of the `ethernet/header` and the `ip/v4/header` types, one can write above `main` function as follows.
```koka
fun main(packet: xdp/packet)
  if val <<eth:ethernet/header, rest:_>> = packet.data else xdp/Pass
  if eth.proto == Ipv4 else xdp/Pass
  if val <<ip:ip/v4/header, rest:_>> = rest else xdp/Pass
  if ip.proto == Tcp else xdp/Pass
  ...
```
This has several advantages:
- we _reuse_ the underlying binary data in the same way our original C function does;
- we don't need to add support for tuples.

#pagebreak()
== Theory

For a language with numbers, bitstrings, optionals and pattern matching.

#let name = (
  b: "b",
  n: "n",
  i: "i",
  ptr: "ptr",
  size: "size",
  bytes: "bytes",
  option: "option",
  type: "type",
  number: "number",
  region: "region",
)
#for (n,v) in name { name.at(n) = value(v) }

#let sep = $; space$
#let typ(x, t, d) = $keyword("type") #x = #t sep #d$
#let fun(x, ps, e, d) = $keyword("fun") #x \(#ps\) space #e sep #d$
#let val(x, e, d) = $keyword("val") #x = #e sep #d$
#let var(x, e, d) = $keyword("var") #x := #e sep #d$
#let app(x, ps) = $#x\(#ps\)$
#let con = app

#let toption(x) = $#x keyword("?")$
#let tstruct(fs) = $keyword("struct") \{#fs\}$
#let tenum(w, vs) = $keyword("enum", script: #w) zws \{#vs\}$

#let bytes(es) = $<< es >>$
#let None = $value("None")$
#let Some = $value("Some")$
#let match(t, e, ps) = $keyword("match", script: #t) zws #e space \{#ps\}$
#let ifvalelse(t, p, e, r, c) = $keyword("if") keyword("val", script: #t) #p zws = #e keyword("else") #r sep #c$

#let tr(x, t) = $bracket.l.double #x bracket.r.double_#t$
#let repr(x) = $"repr"(#x)$

#grid(columns: 2,
  [
    === Terms

    #grammar("Declarations", $d$,
      $typ(X, tau, d)$, [type declarations],
      $fun(x_0, many(x : tau, n), e, d)$, [function declarations],
      $val(x, e, d)$, [value declarations],
    )

    #grammar("Expressions", $e$,
      $N.nu$, [numbers],
      $<< many(e, n) >>$, [bit strings],
      $None$, [none options],
      $con(Some, e)$, [some options],
      $con(X, many(e, n))$, [struct creations],
      $e.x$, [field accesses],
      $match(tau, e_0, many(p |-> e, n))$, [pattern matches],
      $ifvalelse(tau, p_0, e_0, e_1, e_2)$, [pattern guards],
    )

    #grammar("Patterns", $p$,
      // $x$, [variable patterns],
      $None$, [none patterns],
      $con(Some, x)$, [some patterns#footnote[We don't allow nested patterns here.]],
      $<< many(x : tau, n) >>$, [bit string patterns#footnote[Idem.]],
    )

    === Constants

    #grammar("Widths", $W$,
      $8 | 16 | 32 | 64$, [widths],
    )
    #grammar("Numbers", $N$,
      $0 | 1 | ...$, [numbers],
    )
  ],[
    === Types

    #grammar("Types", $tau$,
      // $x$, [type names],
      $nu$, [number types],
      $name.bytes\(N)$, [byte types],
      $toption(tau)$, [option types],
      $tstruct(many(l : tau, n))$, [struct types],
      $tenum(W, many(L, n))$, [enum types],
      // $alpha$, [type variables],
    )

    #grammar("Number types", $nu$,
      $name.b\W | name.n\W | name.i\W$, [numbers],
    )

    // #grammar("Kinds", $kappa$,
    //   $name.type$, [types],
    //   $name.number$, [numbers],
    //   $name.region$, [regions],
    // )

    #grammar("Representations", $rho$,
      $W$, [concrete widths],
      $name.ptr$, [pointers],
      $name.ptr + name.size$, [fat pointers],
    )
    #grammar("Sizes", $sigma$,
      $W$, [sizes],
      $sigma_1 + sigma_2$, [structs],
      $sigma times N$, [arrays],
    )
  ]
)

=== Metrics

#let size = smallcaps("size")

#set table(stroke: none)
#show table.cell.where(y: 0): smallcaps

#table(columns: 4,
  table.hline(),
  [Type], [Name], [Repr], [Size],
  table.hline(),
  $(name.b|name.n|name.i)W$, [numbers], $W$, $W$,
  $name.bytes\(N)$, [bytes], $name.ptr + name.size$, $8 times N$,
  $toption(tau)$, [options], $name.ptr$, $size(tau)$,
  $tstruct(many(x : tau, n))$, [structs], $name.ptr$, $Sigma_n tau_n$,
  $tenum(W, many(x, n))$, [enums], $W$, $W$,
  // $alpha$, [name variables], $name.ptr$, $arrow.zigzag$,
  table.hline(),
)

#pagebreak()
=== Translation

#set raw(lang: "c")

#function($tr("Expression", "Type") -> "C-code"$,
  $tr(N.nu, nu)$, [`(`$nu$`)`$N$],
  $tr(<< many(e, n) >>, name.bytes)$, [`(uint8_t*){`$tr(many(e, n), name.b\8)$`}`],
  $tr(None, name.option\(tau\))$, [`NULL`],
  $tr(Some(e), name.option\(tau\))$, $tr(e, tau)$,
  $tr(L\(many(l = e, n)\), tstruct(many(l : tau, n)))$, [`(struct `$L$`*){`$many(tr(e, tau), n)$`}`],
  $tr(e.l, tau)$, [`(`$tr(e, tau)$`)->l`],
  // $tr(match(option(tau), e_0, Some(x) -> e_2\, None |-> e_1), tau)$, [],
  $tr(ifvalelse(toption(tau), con(Some, x), e_0, e_1, e_2), tau)$, [
    `if (`$tr(e_0, toption(tau))$` == NULL) { return `$tr(e_1, tau)$` }`\
    $tr(e_2, tau)$
  ],
  // $tr(match(bytes, e_0, << x_1 : tau_1\, x_2 : _ >> zws |-> e_1\, \_ |-> e_2), tau)$, [`if (`$tr(tau_1, "")$` x = `$tr(e_0, tau_1)$`; )`],
  // $tr(match(bytes, e_0, << many(x : tau, n) >> zws |-> e_2\, \_ |-> e_1), tau)$, [see below],
  $tr(ifvalelse(bytes, << many(x : tau, n) >>, e_0, e_1, e_2), tau)$, [see below, with $r_i$ and $s_i$ fresh for all $i$],
)

#function($tr("Type", "") -> "C-code"$,
  $nu$, [$nu$],
  $name.bytes\(N)$, [`bytes_t`\
    where#footnote[Probably this needs some extra work, as eBFP doesn't support passing structs as parameters.]
    `typedef struct {size_t size; uint8_t *data} bytes_t;`
  ],
  $toption(tau)$, [$tr(tau, "")$ which can be `NULL`],
  $tstruct(many(l : tau, n))$, [`struct {`$many(tr(l, tau), n)$`}`],
)

#grid(columns: (1fr, 1fr),
  [
    #function($tr("Expression-list", "Type") -> "C-code"$,
      $tr(empty, \_)$, [`/* end */`],
      $tr(e_0 :: many(e, n), tau)$, [$tr(e_0, tau)$`, `$tr(many(e, n), tau)$],
    )
  ],[
    #function($tr("Label-list", "") -> "C-code"$,
      $tr(empty, "")$, [`/* end */`],
      $tr(l_0 : tau_0 :: many(l, n), "")$, [$l$`: `$tr(tau_0, "")$`, `$tr(many(l, n), "")$],
    )
  ]
)

==== Translating pattern matching on bitstrings

#set enum(start: 0)

+ Start by evaluating $e_0$.
  \ `bytes_t *`$r_0$` = `$tr(e_0, tau)$`;`
+ To translate the first pattern match, we calculate the size of type $tau_1$.
  \ `size_t `$s_1$` = sizeof(`$tr(tau_1, "")$`);`
+ Now, if there is not enough data available for $tau_1$, bail out with $e_1$.
  \ `if (`$r_0$`->size < `$s_1$`) { return `$tr(e_1, tau)$` }`
+ Otherwise, we continue by casting the bytes to the desired type.
  \ $tr(tau_1, "")$` `$x_1$` = `$r_0$`->data;`\
+ To prepare for the next pattern, we decrease the size and increase the data pointer.
  \ `bytes_t *`$r_1$` = {`$r_0$`->size - `$s_1$`, `$r_0$`->data + `$s_1$`};`\
+ Repeat steps 1 till 4 for all next patterns.
  \ $...$
+ Finally, execute the happy path.
  \ $tr(e_2, tau)$\
