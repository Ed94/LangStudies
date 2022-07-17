## Concatenation

Regex : `/^AB%/`
Psuedo: `str.start str(AB) str.end`

Machine:
```
->o --A--> o --epsilon--> o --B--> (o)

Submachine_A --epsilon--> Submachine_B
```

## Union

Regex : `/^A|B$/`
Psuedo: `str.start glyph(A) | glyph(B) str.end`

Machine:
```
    epsilon--> o --A--> o --epsilon
   /                               \
->o                                 ->(o)
   \                               /
    epsilon--> o --B--> o --epsilon
```

## Kleene Closure

Regex : `/^A*$/`
Psuedo: `str.start glyph(A).repeating str.end`

Machine:
```
                   <------episolon-------
                  /                      \
->o --epsilon--> o --A--> o --epsilon--> (o)
   \                                     /
    -------------epsilon---------------->
```
