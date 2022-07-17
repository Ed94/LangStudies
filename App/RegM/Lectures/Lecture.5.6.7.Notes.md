## Concatenation

Regex : `/^AB$/`
Psuedo: `start str(AB) end`

Machine:
```
->o --A--> o --epsilon--> o --B--> (o)

Submachine_A --epsilon--> Submachine_B
```

## Union

Regex : `/^A|B$/`
Psuedo: `start glyph(A) | glyph(B) end`

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
Psuedo: `start glyph(A).repeating end`

Machine:
```
                   <------episilon-------
                  /                      \
->o --epsilon--> o --A--> o --epsilon--> (o)
   \                                     /
    -------------epsilon---------------->
```
