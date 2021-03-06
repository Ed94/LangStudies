SRegex Notes

Test Cases:
```
RegEx					SRegex

.						inline
\w						word
\d						digit
\s						whitespace
\W 						!word
\D						!digit
\S						!whitespace
[abc]					set(abc)
[^abc]					!set(abc)
[a-g]					set(a-g)
^abc$					start abc end
\bstring\b				"string"
\Bnot this string\B		!"not this string"
						\-  				(NOTE: Used by between token)
						\.					(NOTE: Used by .lazy, .repeat)
						\!					(NOTE: Used as not operator)
						\|					(NOTE: Used as union operator)
						\(					(NOTE: Used for captures, set, ref)
						\)					(NOTE: Used for captures, set, ref)
						\"					(NOTE: Used for strings)
\t					
\n
\r
(abc)					( abc )
\1						backref(1)
(?:abc)					!( abc )
(?=abc)					look(abc)
(?!abc)					!look(abc)
a*						a.repeat(0-)
a+						a.repeat(1-)
a?						a.repeat(0-1)
a{5}					a.repeat(5)
a{2,}					a.repeat(2-)
a{1,3}					a.repeat(1-3)
a{5}					a.repeat(0-).lazy
a{2,}?					a.repeat(2-).lazy
ab|cd					ab | cd
/^\/\*[\s\S]*?\*\//		start /* set(whitespace !whitespace).repeat(0-).lazy */							
```

```
inline
word
digit
whitespace
!word
!digit
!whitespace
set(abc)
!set(abc)
set(a-g)
start abc end
"string"
!"not this string"
\- 
\.
\!
\|
\(
\)
\"
\t
\n
\r
( abc )
backref(1)
!( abc )
look(abc)
!look(abc)
a.repeat(0-)
a.repeat(1-)
a.repeat(0-1)
a.repeat(5)
a.repeat(2-)
a.repeat(1-3)
a.repeat(0-).lazy
a.repeat(2-).lazy
ab | cd

start whitespace
start "start"
start "end"
start \" !set( \" ).repeat(0-) "\
start \ \(
start \ \)
start \(
start \)
start \-
start "digt"
start "inline"
start "word"
start "whitespace"
start "lazy"
start \."repeat"
start \\ \-
start \\ \.
start \\ \!
start \\ \|
start \\ \"
start "look"
start \!
start \|
start "backref"
start "set"
start !set(whitespace)

start // inline.repeat(0-)
start /* set(whitespace !whitespace).repeat(0-).lazy */		start
start whitespace.repeat(1-)
start ,
start \.
start ;
start {
start }
start "let"
start "class"
start "while"
start "do"
start "for"
start "def"
start "return"
start "if"
start "else"
start "new"
start "extends"
start "super"
start set(> <) =.repeat(0-1)
start set(= \!) =
start &&
start \| \|
start \!
start set( * / + \- ) =
start =
start set(+ \-)
start set( * / )
start "true"
start "false"
start digit.repeat(1-)
start \" !set( \" ).repeat(0-) \"
start "null"
start "this"
start word.repeat(1-)


(?# Url checker with or without http:// or https:// )
start(
	http://www\.
|	https://www\.
|	http://
|	https://
).repeat(0-1)

set(a-z 0-9).repeat(1-) 

(   (?# Check for any hypens or dot namespaces )
	set(\-  \. ).repeat(1)
	set(a-z 0-9).repeat(1-)
)
.repeat(0-)

(?# Domain name )
\. set(a-z).repeat(2,5)

(?# Possibly for a port? )
( : set(0-9).repeat(1-5) ).repeat(0-1)

(?# I have no idea... )
( / \. \*).repeat(0-1)
end

(?# Validate an IP Address)
start(
	
	(      set(0-9)
	|	   set(1-9) set(0-9)
	|	1  set(0-9).repeat(2)
	|	2  set(0-4) set(0-9)
	|	25 set(0-5)
	)
	\.
)
.repeat(3)

(
	   set(0-9)
|	   set(1-9)set(0-9)
|	1  set(0-9).repeat(2)
|	2  set(0-4) set(0-9)
|	25 set(0-5)
)
end

(?# Match dates (M/D/YY, M/D/YYY, MM/DD/YY, MM/DD/YYYY) )
start
(
	(?# Handle Jan, Mar, May, Jul, Aug, Oct, Dec )
	( 0.repeat(0-1) set(1 3 5 7 8) | 10 | 12 )

	( \- | / )
	(	(?# Handle Day )
		(   set(1-9))
	|	( 0 set(1-9))
	|	(   set(1 2)) 
		(   set(0-9).repeat(0-1))
	|	( 3 set(0 1).repeat(0-1))
	)

	( \- | / )
	(	(?# Handle Year)
		(19)
		( set(2-9))
		( digit.repeat(1) ) 
	|	(20)
		( set(0 1))
		( digit.repeat(1) )
	|	( set(8 9 0 1))
		( digit.repeat(1))
	)

|	(?# Handle Feb, Apr, June, Sept )
	( 0.repeat(2 4 6 9) | 11 )

	( \- | /)
	(   (?# Handle Day )
		(   set(1-9))
	|	( 0 set(1-9))
	|	(   set(1 2))
		(   set(0-9).repeat(0-1))
	|	( 3 set(0  ).repeat(0-1))
	)

	( \- | / )
	(
		(?# Handle Year)
		(19)
		( set(2-9) )
		( digit.repeat(1) )
	|	(20)
		( set(0 1))
		( digit.repeat(1) )
	|	( set(8 9 0 1 ))
		( digit.repeat(1))
	)
) 
end
