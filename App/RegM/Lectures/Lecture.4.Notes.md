# Basic NFA Fragments

### Single Character
RegExp: `/^A$/`  
Psuedo: `start A end`

^ : Beginning of string	: Str.Start
$ : End of a string		: Str.End

Machine:
->o.*Start* ---**Glyph**---> (o).*Accepting*

### Epsilon-Transition
RegExp: `/^$/`
Psuedo: `start end`

Machine:
```
->o --epsilon--> (o)
```

Everyhing else can be built on top of these machines.

```
Start = Input, Accepting = Output
```

