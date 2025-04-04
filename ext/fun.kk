module ext/fun

pub fun guard(p: bool, yes: () -> e ()): e ()
  if p
    then yes()
    else ()

pub fun guard-or-else(p: bool, nop: () -> e a, yes: () -> e a): e a
  if p
    then yes()
    else nop()