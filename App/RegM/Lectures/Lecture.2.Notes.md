# Symbols, alphabets, and langauges and Regular Grammars

Alphabet : A set of characters.

Sigma = { a, b }

Langauge : A set of strings over a particular alphabet.

L1(Sigma) = { a, aa, b, ab, ba, bba, .. } (Infinite)
L2(Sigma) = { aa, bb, ab, ba }; (Length = 2, Finite)

Any time you constrain a langauge you are 
defining a formal grammar.

## Formal Grammars:

FormalGrammer = (Non-Terminals, Terminals, Productions, Starting Symbol)

Non-Terminals : Variables (can be subsituted with a value)
Terminals     : Cannot be replaced by anything (constant)
Productions   : Rule in the grammar

**G = (N, T, P, S)**

Ex:
```
S -> aX
X -> b
```
**(This notation is known as BNF : Bakus-Naur Form)**

Ex.Non-Terminals   = S, X
Ex.Terminals       = a, b
Ex.Productions     = S -> aX, X -> b (2)
Ex.Starting Symbol = S

Only valid string : "ab"

## Chomsky Hierachy :

0. Unrestricted      : Natural Langauges, Turing Machines
1. Context-Sensitive : Programming Languages (Almost all in production)
2. Context-Free      : Programming Langauges (Parsing Syntax only)
3. Regular           : Regular Expressions

The lower in the hiearchy the less expressive it is.

RegExp is a vomit inducing terse notation that is equivalent to BNF.

BNF          : RegExp
S -> aS      : 
S -> bA      : `a*bc*`
A -> epsilon :
A -> cA      :

epsilon : "The empty string".

Regular expressions may only have one non-terminal:
* A the very right side (right-linear, RHS)
* At the very left side (left-linear, LHS)

Regular expression have no support for *NESTING*
They can be *RECURSIVE*

Context-free grammers support nesting.
Ex:
(( () ))
`Parenthesis balacing`

Non-regular RegExp can support nesting but are not pure
finite automata and are slower implementation.



