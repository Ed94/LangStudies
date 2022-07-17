# Complex Machines 

Ex:

RegEx : `/xy*|z`  
SRegEx: `x y.repeat(0-) | z`

## Decomposition

### Stage 1: Union
```
->o.start                            (o)
   \epsilon-> o --xy*-> o -epsilon-->/
   \epsilon-> o --z---> o -epsilon->/
```
### Stage 2: Concatenation
```
->o.start                                             (o)
   \epsilon -> o --x--> o -epsilon-> o --y* -epsilon->/
   \epsilon -> o --z--> o -epsilon------------------>/
```
### Stage 2: Kleene Closure
```
                                       |<------------<|
  ->epsi -> o -x-> o -epsi-> o -epsi-> o -y-> -epsi-> o ->epsi->|
  |                          |>---------------------->|         /
->o.start                                                     (o)
   \epsi -> o -z-> o -epsi------------------------------------>/
```

