# Pipeline

Interpretation Involves **RUNTIME SEMANTICS**

***THE MEANING OF THE PROGRAM MODEL***

Compliation delegates semantics of runtime behavior to
***a TARGET language***

Interpetation deals with the semantics itself.

Types of Interpreter **implementation**:
* AST-based (recursive)
* Bytecode (Virtual Machines)

Types of Compiler **implementation**:
* Ahead-of-time (AOT)
* Just-in-time (JIT)

## Interpeter-AST:

**Translation Stage:**
1. Program Model
2. Lexer: Processing into token elements for a parser.
	* Output : Tokens
3. Parser: Syntactic Analysis
	* Output : Abstract Syntax Tree (AST)

**Runtime Stage:**
4. Interpeter
5. Runtime Behavior

## Interpreter-Bytecode:

**Translation Stage:**
1. Program Model
2. Lexer: Processing into token elements for a parser.
	* Output : Tokens
3. Parser: Syntactic Analysis
	* Output : Abstract Syntax Tree (AST)
4. Bytecode Emitter
5. Bytecode instructions primed.

**Runtime Stage:**
6. Interpreter
7. Runtime Behavior


**Types of Virtual Machine behavior:**
* Stack based
	* Stack for operands and operators
	* Result is always on top of stack
* Register based
	* Virtual registers
	* Result in accumulation register
	* Map to real via register allocation

## Compiler Ahead-of-Time:
1. Program Model
2. Lexer: Processing into token elements for a parser.
	* Output : Tokens
3. Parser: Syntactic Analysis
	* Output : Abstract Syntax Tree (AST)
4. Code Generator
5. Intermediate representation primed
6. Target machine instruction set code generation
7. Target machine is intended interpretation platform.
8. Runtime Behavior.


## Compiler with LLVM platform:
1. Program Model
2. Lexer: Processing into token elements for a parser.
	* Output : Tokens
3. Parser: Syntactic Analysis
	* Output : Abstract Syntax Tree (AST)
4. LLVM IR generator
5. LLVM Native code generator
6. Target machine is intended interpretation platform
7. Runtime Behavior.


Lexer, and parser are considered **FRONT-END**.  
Code Generation or byte-code gen or interpreter ast impelementation gen
for target instruction platform is considered **BACK-END**.


## Jit Compiler:
1. Program Model
2. Lexer: Processing into token elements for a parser.
	* Output : Tokens
3. Parser: Syntactic Analysis
	* Output : Abstract Syntax Tree (AST)
4. Bytecode Emitter
5. Bytecode fed to interpeter
6. Interetor may code gen immediately to target hardware platform or interpret ast directly.
7. Runtime Behavior.

## Transpiler:
1. Program Model in input langauge
2. Lexer: Processing into token elements for a parser.
	* Output : Tokens
3. Parser: Syntactic Analysis
	* Output : Abstract Syntax Tree (AST)
4. AST Transformation to target AST
5. Code generation
6. Program Model in output langauge



