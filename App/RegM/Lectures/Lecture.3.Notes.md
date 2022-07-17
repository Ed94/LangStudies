# Finite Automata
***(AKA: Finite State Machine)***

Mechanism and abstraction used behind regular grammars.

Usually has its state represented using nodes and edges.

Regular grammar:
```
S -> bA
A -> epsilon
```
Equivalent to: `\b\`

State transition:

--label--> : Transition symbol 
O          : State Symbol
(o)        : Accepting State
->O.Start  : Starting State (State transition to Start)

Ex:

->O.*Start* --*transition*--> (o).*Accepting*

*ε* - Epsilon (Empty String)
`I will be spelling it out as I do not enjoy single glyth representation`

Two main types of Finite Automtata :

FA w/ output
* Moore machine
* Mealy machine

FA w/o output
* DFA - Deterministic
* NFA - Non-deterministic
* epsilon-NFA - (Epsilon Transition) special case

NFA : Non-deterministic FA - Allos transition on the same symbol to
different states

```
    a->o
   /
->o.1---b-->o
   \
    a->o 
```

epsilon-NFA : Extension of NFA that allows *epsilon* transitions

```
    a--->o---epsi--->(o)
   /                /
->o----b-->epsi--->o
   \
    a-->o--epsi-->(o)
```

DFA : A state machine which forbids multiple transitions on the same symbol, and *epsilon* transitions

```
    a--->o
   /
->o----b-->o
```

Use case:

Implementation Transformations:
```RegExp -> epsilon-NFA -> ... -> DFA```

## Formal Definition:

Non-deterministic finite automata is a tuple of five elements:
* All possible states
* Alphabet
* Transition Function
* Starting State
* Set of accepting states

NFA = ( States, Alphabet, TransitionFunction, StartingState, AcceptingStates )

NFA = ( Q, Σ, Δ, q0, F )
