## Concatenation

Regex : `/^AB$/`  
Psuedo: `start AB end`  

Machine:
```
->o --A--> o --epsilon--> o --B--> (o)

Submachine_A --epsilon--> Submachine_B
```

## Union

Regex : `/^A|B$/`  
Psuedo: `start A | B end`

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
Psuedo: `start A.repeat(0-) end`

Machine:
```
                   <------episilon-------
                  /                      \
->o --epsilon--> o --A--> o --epsilon--> (o)
   \                                     /
    -------------epsilon---------------->
```
