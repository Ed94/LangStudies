# Eva Programming Langauge

Dynamic programming langauge.

Simple syntax, functional heart, OOP support.

## Eva Expressions:
```
(<type> <op1> <op2> ... <opN>)
```

Example:
```
(+ 5 10)
(set x 15)

(if (> x 10)
	(print "ok")
	(print "error")
)
```

```
(def foo (bar)
	(+ bar 10)
)
```

```
(lambda (x) (* x x) 10)
```

## Design Goals

* Simple syntax: S-Expression
* Everything is an expression
* No explicit return, last evalulated expression is the result
* First class functions
* Static scope: all functions are closures
* Lambda functions
* Funcitonal programming
* Imperative programming
* Namespaces and modules
* OOP: Class or prototype based.

