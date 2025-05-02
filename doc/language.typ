#import "lib/helpers.typ": *
#import "lib/commands.typ": *
#import "lib/setups.typ": setups

#show: setups
#set page(margin: 1.5cm)

= Theory

== Syntax

#let name = (
  b: "b",
  n: "n",
  i: "i",
  box: "box",
  unbox: "unbox",
  ptr: "ptr",
  size: "size",
)
#for (n,v) in name { name.at(n) = value(v) }

#let pr(..x) = $angle.l #x.pos().intersperse($,$).join() angle.r$
#let tr(x, t) = $bracket.l.double #x bracket.r.double_#t$

#let sep = $; space$
#let typ(x, t, d) = $keyword("type") #x = #t sep #d$
#let fun(x, ps, e, d) = $keyword("fun") #x \(#ps\) space #e sep #d$
#let val(t, x, e, d) = $keyword("val")_#t #x = #e sep #d$
#let var(x, e, d) = $keyword("var") #x := #e sep #d$
#let app(x, ps) = $#x\(#ps\)$
#let con = app

#let tunit = $value("unit")$
#let tfun(ps, e, r) = $\(#ps\) -> #e space #r$
#let tbytes = $value("bytes")$ //pr(#n)$
#let tarray(n, a) = $value("array")pr(#n, #a)$
#let toption(t) = $value("option")pr(#t)$ // keyword("?")$
#let tbox(t) = $value("box")pr(#t)$
#let tmap(t1, t2) = $value("map")pr(#t1, #t2)$
#let tstruct(fs) = $keyword("struct") \{#fs\}$
#let tenum(w, vs) = $keyword("enum", script: #w) zws \{#vs\}$

#let bytes(es) = $<< es >>$
#let string(x) = $\"#x\"$
#let True = $value("True")$
#let False = $value("False")$
#let None = $value("None")$
#let Some = $value("Some")$
#let box = $value("box")$
#let unbox = $value("unbox")$

#let match(t, e, ps) = $keyword("match", script: #t) zws #e space \{#ps\}$
#let ifvalelse(t, p, e, r, c) = $keyword("if") keyword("val", script: #t) #p zws = #e keyword("else") #r sep #c$
#let ifthenelse(p, t, e) = $keyword("if") #p keyword("then") #t keyword("else") #e$

#let repr(x) = $"repr"(#x)$

#grid(columns: 2, [

=== Terms

#grammar("Declarations", $d$,
  $typ(x, tau, d)$, [type declarations],
  $fun(x_0, many(x : tau, n), e, d)$, [function declarations],
  $val(tau, x, e, d)$, [value declarations#footnote[
    Only allow constants?
  ]],
)

#grammar("Expressions", $e$,
  $x$, [variables],
  $a$, [addresses],
  $c$, [constructions],
  // Binding, application, lookup
  $val(tau, x_0, e_0, e)$, [bindings],
  $app(e_0, many(e, n))$, [applications],
  $e_1 space o space e_2$, [binary operators],
  $u space e_1$, [unary operators],
  $e.x$, [field accesses],
  // Branching
  $match(tau, e_0, many(p |-> e, n))$, [pattern matches],
)

#grammar("Constructions", $c$,
  $()$, [unit],
  $N.nu$, [numbers],
  $True | False$, [bools],
  $None | con(Some, e)$, [options],
  $<< many(e, n) >>$, [bit strings],
  // $string(...)$, [strings],
  $con(X, many(e, n))$, [structs],
)

#grammar("Patterns", $p$,
  // $x$, [variable patterns],
  $()$, [unit pattern],
  $N.nu$, [number patterns],
  $True | False$, [bool patterns],
  $None | con(Some, x)$, [option patterns#footnote[We don't allow nested patterns here.]],
  $<< many(x : tau, n) >>$, [bit string patterns],
  // $string(...)$, [string patterns],
  $con(X, many(x, n))$, [struct patterns#footnote[Idem.]],
)

#grammar("Binary operators", $o$,
  $ + | - | * | "/" | % $, [calculations],
  $ < | <= | equiv | equiv.not | >= | > $, [comparisons],
  $ and | or $, [comparisons]
)

#grammar("Unary operators", $u$,
  $box$, [boxing#footnote[
    Explicitly calling it _boxing_ to minimise confusion.
  ]],
  $unbox$, [unboxing],
  $-$, [negating],
)

],[

=== Types

#grammar("Types", $tau$,
  // $alpha$, [type variables],
  $tunit$, [unit type#footnote[
    The unit type has just one inhabitant, so it doesn't need a representation.
  ]],
  $upsilon$, [value types],
  $pi$, [pointer types],
  $phi$, [fat pointer types],
)

#grammar("Value types", $upsilon$,
  $nu$, [number types],
  $tenum(W, many(L, n))$, [enum types],
)

#grammar("Number types", $nu$,
  $name.b\W$, [bits],
  $name.n\W$, [naturals],
  $name.i\W$, [integers],
)

#grammar("Pointer types", $pi$,
  $tfun(many(tau, n), eta, tau_0)$, [function types],
  $tbox(tau)$, [boxed types#footnote[
    Explicitly calling it _box_ to minimise confusion.
  ]],
  $toption(pi)$, [option types],
  $tmap(pi_1, pi_2)$, [map types],
  $tstruct(many(l : tau, n))$, [struct types],
)

#grammar("Fat pointer types", $phi$,
  $tbytes$, [bytes type],
)

// #grammar("Kinds", $kappa$,
//   $name.type$, [types],
//   $name.number$, [numbers],
//   $name.region$, [regions],
// )

=== Effects

// #grammar("Representations", $rho$,
//   $W$, [concrete widths],
//   $name.ptr$, [pointers],
//   $name.ptr + name.size$, [fat pointers],
// )
// #grammar("Sizes", $sigma$,
//   $W$, [sizes],
//   $sigma_1 + sigma_2$, [structs],
//   $sigma times N$, [arrays],
// )

=== Constants

#grammar("Widths", $W$,
  $8 | 16 | 32 | 64$, [widths],
)
#grammar("Numbers", $N$,
  $0 | 1 | ...$, [numbers],
)

])

=== Sugar


#grammar("Expressions", $e$,
  $ifthenelse(e_0, e_1, e_2)$, [branches],
  $ifvalelse(tau, p_0, e_0, e_1, e_2)$, [pattern guards],
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
  $tbytes$, [bytes], $name.ptr + name.size$, $8 times N$,
  $toption(pi)$, [options], $name.ptr$, $size(pi)$,
  $tstruct(many(x : tau, n))$, [structs], $name.ptr$, $Sigma_n tau_n$,
  $tenum(W, many(x, n))$, [enums], $W$, $W$,
  // $alpha$, [name variables], $name.ptr$, $arrow.zigzag$,
  table.hline(),
)

- Bytes are represented by _two_ pointers, one to the start and one to the end of the data.
- Adding arrays would complicate things,
  as we'd need to extend the type system with lengths to write
  $tarray(N,alpha)$
  for an array of length $N$ with elements of type $alpha$.

=== Translation

#set raw(lang: "c")

#function($tr("Expression", "Type") -> "C-code"$,
  $tr(N.nu, nu)$, [`(`$nu$`)`$N$],
  $tr(<< many(e, n) >>, tbytes)$, [`(uint8_t*){`$tr(many(e, n), name.b\8)$`}`],
  $tr(None, toption(pi))$, [`NULL` (should only work if $tau$ is a reference type)],
  $tr(Some(e), toption(pi))$, [$tr(e, tau)$ (idem)],
  $tr(L\(many(l = e, n)\), tstruct(many(l : tau, n)))$, [`(struct `$L$`*){`$many(tr(e, tau), n)$`}`],
  $tr(e.l, tau)$, [`(`$tr(e, tau)$`)->l`],
  // $tr(match(option(tau), e_0, Some(x) -> e_2\, None |-> e_1), tau)$, [],
  $tr(ifvalelse(toption(pi), con(Some, x), e_0, e_1, e_2), pi)$, [
    `if (`$tr(e_0, toption(pi))$` == NULL) { return `$tr(e_1, pi)$` }`\
    $tr(e_2, pi)$
  ],
  // $tr(match(bytes, e_0, << x_1 : tau_1\, x_2 : _ >> zws |-> e_1\, \_ |-> e_2), tau)$, [`if (`$tr(tau_1, "")$` x = `$tr(e_0, tau_1)$`; )`],
  // $tr(match(bytes, e_0, << many(x : tau, n) >> zws |-> e_2\, \_ |-> e_1), tau)$, [see below],
  $tr(ifvalelse(bytes, << many(x : tau, n) >>, e_0, e_1, e_2), tau)$, [see below, with $r_i$ and $s_i$ fresh for all $i$],
)

#function($tr("Type", "") -> "C-code"$,
  $nu$, [$nu$],
  $tenum(W, many(L, n))$, [`enum {`$many(L, n)$`}`],
  $tbytes$, [`bytes_t`\
    where#footnote[
      Maybe this needs some extra work, as eBFP doesn't support passing structs as parameters.
    ] #footnote[
      More ideal would be to use
      `typedef struct {uint8_t *data; size_t size} bytes_t;`
      instead of above definition,
      but most data in the Linux kernel seems to be encoded with begin- and end-pointers.
      This means that we can easily cast all structs that begin with `data` and `data_end` pointers to our `bytes_t` type.
    ]
    `typedef struct {uint8_t *start; uint8_t *end} bytes_t;`
  ],
  $tbox(tau)$, [`void*`],
  $toption(pi)$, [$tr(pi, "")$ which can be `NULL`],
  $tmap(pi_1,pi_2)$, [`void*`],
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

+ Start by evaluating $e_0$ and cast it to our `bytes_t` type.
  \ `bytes_t *`$r_0$` = `$tr(e_0, tau)$`;`
+ To translate the first pattern match, we calculate the size of type $tau_1$.
  \ `size_t `$s_1$` = sizeof(`$tr(tau_1, "")$`);`
+ Now, if there is not enough data available for $tau_1$, bail out with $e_1$.#footnote[
    We need to make sure this check is right, ±1 byte is important!
    Also, maybe `size_t` needs to be casted to something to do the pointer arithmetic, I didn't check this.
  ] #footnote[
    Note that, indeed, $e_1$ is copied $n$ times if there are $n$ bitstring patterns.
  ]
  \ `if (`$r_0$`->start + `$s_1$` > `$r_0$`->end) { return `$tr(e_1, tau)$` }`
+ Otherwise, we continue by casting the bytes to the desired type.
  \ $tr(tau_1, "")$` `$x_1$` = `$r_0$`->data;`\
+ To prepare for the next pattern, we move the start pointer of the byte slice.
  \ `bytes_t *`$r_1$` = {`$r_0$`->start + `$s_1$`, `$r_0$`->end};`\
+ Repeat steps 1 till 4 for all next patterns.
  \ $...$
+ Finally, execute the happy path.
  \ $tr(e_2, tau)$\
