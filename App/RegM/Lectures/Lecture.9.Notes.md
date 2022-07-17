# Syntactic Sugar

Ex:

RegEx : `/a+|[0-3]/`  
SRegEx: `a.repeat(1-) | set(0-3)`

`A+` === `AA*` === `A.repeat(1-)`  === `AA.repeat(0-)`  
`A?` === `A|ε` === `A.repeat(0-1)`  

`[0-9]` === `0|1|2|3|4|5|6|7|8|9` === `set(0-9)`

# NFA Optimizations

Ex:

RegEx : `/[0-2]+/`  
SRegEx: `set(0-2).repeat(1-)`

Machine (Optimized):
```
  |<-epsi-<|
->o -0-> (o)
  \--1-->/
   \-2->/
```

A* (Optimized)
```
->o -A--> (o)
  \-epsi->/
```
`[characters]`
```
->o --<num>--> (o)
	..........
```


