# Basic NFA Fragments

### Single Character
RegExp: `/^A$/`
Psuedo:
`str.start glyph(A) str.end`

^ : Beginning of string	: Str.Start
$ : End of a string		: Str.End

Machine:
->o.*Start* ---**Glyph**---> (o).*Accepting*

### Epsilon-Transition
RegExp: `/^$/`
Psuedo: `str.start str.end`

Machine:
```
->o --epsilon--> (o)
```

Everyhing else can be built on top of these machines.

```
Start = Input, Accepting = Output
```

