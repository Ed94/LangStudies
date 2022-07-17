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
a{5}					a.repeat.lazy
a{2,}?					a.repeat(2-).lazy
ab|cd					ab | cd
/^\/\*[\s\S]*?\*\//		start /* set(whitespace !whitespace).lazy.repeat */							
```