extends Object


# Simple Regular Expressions
# This is a "high-level" langauge and transpiler for regex
# That makes it easier to write out and read
# than the original notation or syntax.
# 
# The main interface function is transpile( <string> )
# Which can take any valid string from gdscript.


# Lexer

const TokenType = \
{
    fmt_S = "Formatting",

    expr_PStart = "Parenthesis Start",
    expr_PEnd   = "Parenthesis End",

    glyph         = "Glyph",
    glyph_between = "Glyphs Between",
    glyph_digit   = "Digit",
    glyph_inline  = "inline",
    glyph_word    = "Word",
    glyph_ws      = "Whitespace",

    glyph_dash    = "-"
    glyph_dot     = ". dot",
    glyph_excla   = "! Mark",
    glyph_vertS   = "|",
    glyph_bPOpen  = "(",
    glyph_bPClose = ")",
    glyph_dQuote  = "\""

    op_lazy   = "Lazy Operator",
    op_look   = "Lookahead",
    op_not    = "Not Operator",
    op_repeat = "Repeating Operator",
    op_union  = "Union Operator",

    ref     = "Backreference Group",
    set     = "Set",

    str_start = "String Start",
    str_end   = "String End",
    string    = "String"
}

const TokenSpec = \
{
    TokenType.fmt_S = "^\\s",

	TokenType.string    = "^\"[^\"]*\"",

    TokenType.expr_PStart = "^\\(",
    TokenType.expr_PEnd   = "^\\)",

    TokenType.glyph_between = "^\\-"
    TokenType.glyph_digit   = "^\\bdigit\\b",
    TokenType.glyph_inline  = "^\\binline\\b",
    TokenType.glyph_word    = "^\\bword\\b",
    TokenType.glyph_ws      = "^\\bwhitespace\\b",

    TokenType.op_lazy   = "^\\b.lazy\\b",
    TokenType.op_repeat = "^\\b\\.repeat\\b",

    TokenType.glyph_dash    = "^\\\-"
    TokenType.glyph_dot     = "^\\\.",
    TokenType.glyph_excla   = "^\\\!",
    TokenType.glyph_vertS   = "^\\\|",
    TokenType.glyph_bPOpen  = "^\\\(",
    TokenType.glyph_bPClose = "^\\\)",
    TokenType.glpyh_dQuote  = "^\\\"",

    TokenType.op_look   = "^\\blook\\b",
    TokenType.op_not    = "^\\!",
    TokenType.op_union  = "^\\|",

    TokenType.ref       = "^\\bbackref\\b",
    TokenType.set       = "^\\bset\\b",
    TokenType.str_start = "^\\bstart\\b",
    TokenType.str_end   = "^\\bend\\b",

    TokenType.glyph     = "^[\\w\\d]"
}


class Token:
	var Type  : String
	var Value : String


var SourceText : String
var Cursor     : int
var SpecRegex  : Dictionary
var Tokens     : Array
var TokenIndex : int = 0


func compile_regex():
	for type in TokenType.values() :
		var \
		regex = RegEx.new()
		regex.compile( Spec[type] )
		
		SpecRegex[type] = regex

func init(programSrcText):
	SourceText = programSrcText
	Cursor     = 0
	TokenIndex = 0

	if SpecRegex.size() == 0 :
		compile_regex()

	tokenize()

func next_Token():
	
	var nextToken = null
	
	if Tokens.size() > TokenIndex :
		nextToken   = Tokens[TokenIndex]
		TokenIndex += 1
	
	return nextToken

func reached_EndOfText():
	return Cursor >= SourceText.length()

func tokenize():
	Tokens.clear()

	while reached_EndOfText() == false :
		var srcLeft = SourceText.substr(Cursor)
		var token   = Token.new()

		var error = true
		for type in TokenType.values() :
			var result = SpecRegex[type].search( srcLeft )
			if  result == null || result.get_start() != 0 :
				continue
			
			# Skip Whitespace
			if type == TokenType.fmt_S :
				var addVal   = result.get_string().length()
				
				Cursor += addVal
				error   = false
				break

			token.Type   = type
			token.Value  = result.get_string()
			Cursor      += ( result.get_string().length() )
			
			Tokens.append( token )
			
			error = false
			break;

		if error :
			var assertStrTmplt = "next_token: Source text not understood by tokenizer at Cursor pos: {value} -: {txt}"
			var assertStr      = assertStrTmplt.format({"value" : Cursor, "txt" : srcLeft})
			assert(true != true, assertStr)
			return

# End : Lexer



# Parser

class ASTNode:
	var Type  : String
	var Value # Not specifing a type implicity declares a Variant type.
	
	func array_Serialize(array, fn_objSerializer) :
		var result = []

		for entry in array :
			if typeof(entry) == TYPE_ARRAY :
				result.append( array_Serialize( entry, fn_objSerializer ))

			elif typeof(entry) == TYPE_OBJECT :
				fn_objSerializer.set_instance(entry)
				result.append( fn_objSerializer.call_func() )

			else :
				result.append( entry )
				
		return result

	func to_SExpression():
		var expression = [ Type ]

		if typeof(Value) == TYPE_ARRAY :
			var \
			to_SExpression_Fn = FuncRef.new()
			to_SExpression_Fn.set_function("to_SExpression")
			
			var array = array_Serialize( self.Value, to_SExpression_Fn )
			
			expression.append(array)
			return expression
			
		if typeof(Value) == TYPE_OBJECT :
			var result = [ Type, Value.to_SExpression() ]
			return result
			
		expression.append(Value)
		return expression
	
	func to_Dictionary():
		if typeof(Value) == TYPE_ARRAY :
			var \
			to_Dictionary_Fn = FuncRef.new()
			to_Dictionary_Fn.set_function("to_Dictionary")
			
			var array = array_Serialize( self.Value, to_Dictionary_Fn )
			var result = \
			{
				Type  = self.Type,
				Value = array
			}
			return result
			
		if typeof(Value) == TYPE_OBJECT :
			var result = \
			{
				Type  = self.Type,
				Value = self.Value.to_Dictionary()
			}
			return result

		var result = \
		{ 
			Type  = self.Type,
			Value = self.Value
		}
		return result

const NodeType = \
{
    expression = "Expression",

    between = "Glyphs Between Set"
    capture = "Capture Group",
    lazy    = "Lazy",
    look    = "Lookahead",
    ref     = "Backreference Group",
    repeat  = "Repeat",
    set     = "Set",
    union   = "Union",

    inline        = "Inline",
    digit         = "Digit",
    inline        = "Any Inline"
    word          = "Word",
    whitespace    = "Whitespace",
    string        = "String"
    strStart      = "String Start",
    strEnd        = "String End",

    glyph = "Glyph",
}


var NextToken   : Token

# --------------------------------------------------------------------- HELPERS

# Gets the next token only if the current token is the specified intended token (tokenType)
func eat(tokenType):
	var currToken = NextToken
	
	assert(currToken != null, "eat: NextToken was null")
	
	var assertStrTmplt = "eat: Unexpected token: {value}, expected: {type}"
	var assertStr      = assertStrTmplt.format({"value" : currToken.Value, "type" : tokenType})
	
	assert(currToken.Type == tokenType, assertStr)
	
	NextToken = next_Token()
	
	return currToken

func is_Glyph() :
    match NextToken:
        TokenType.glyph:
        TokenType.glyph_digit:
        TokenType.glyph_inline:
        TokenType.glyph_word:
        TokenType.glyph_ws:
        TokenType.glyph_dash :
        TokenType.glyph_dot :
        TokenType.glyph_excla :
        TokenType.glyph_vertS :
        TokenType.glyph_bPOpen :
        TokenType.glyph_bPClose :
        TokenType.glyph_dQuote :
            return true

    return false

func is_GlyphOrStr() :
    return is_Glyph() || NextToken.Type == TokenType.string

# --------------------------------------------------------------------- HELPERS

#   > Union
# Union
# : expression | expression ..
# | expression
# ;
func parse_OpUnion():
    var expression = parse_Expression(TokenType.union)

    if NextToken.Type != TokenType.union :
        return expression

    eat(TokenType.op_union)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.union
    node.Value = [ expression, parse_union() ]

    return node

#   > Union
# Expression
#   : EVERYTHING (Almost)
#   ;
func parse_Expression(end_token : Token):
    var \
    node       = ASTNode.new()
    node.Type  = NodeType.Expression
    node.Value = []

    while NextToken != null && NextToken.Type != end_token :
        match NextToken.Type
            TokenType.str_start :
                node.Value.append( parse_StrStart() )

            TokenType.str_end :
                node.Value.append( parse_StrEnd() )
               
            TokenType.expr_PStart :
                node.Value.append( parse_CaptureGroup() )

            TokenType.glyph :
                node.Value.append( parse_Glyph() )

            TokenType.glyph_digit :
                node.Value.append( parse_GlyphDigit() )

            TokenType.glyph_inline :
                node.Value.append( parse_GlyphInline() )

            TokenType.glyph_word :
                node.Value.append( parse_GlyphWord() )

            TokenType.glyph_ws :
                node.Value.append( parse_GlyphWhitespace() )


            TokenType.glyph_dash :
                node.Value.append( parse_GlyphDash() )

            TokenType.glyph_dot :
                node.Value.append( parse_GlyphDot() )

            TokenType.glyph_excla :
                node.Value.append( parse_GlyphExclamation() )

            TokenType.glyph_vertS :
                node.Value.append( parse_GlyphVertS() )

            TokenType.glyph_bPOpen :
                node.Value.append( parse_Glyph_bPOpen() )

            TokenType.glyph_bPClose :
                node.Value.append( parse_Glyph_bPClose() )
                
            TokenType.glyph_dQuote :
                node.Value.append( parse_Glyph_DQuote() )


            TokenType.op_look :
                node.Value.append( parse_OpLook() )

            TokenType.op_not :
                node.Value.append( parse_OpNot() )

            TokenType.op_repeat:
                node.Value.append( parse_OpRepeat() )

            TokenType.ref :
                node.Value.append( parse_Backreference() )

            TokenType.set :
                node.Value.append( parse_Set() )

            TokenType.string :
                node.Value.append( parse_String() )

    return node

#   > Expression
func parse_StrStart():
    eat(TokenType.str_start)

    var \
    node      = ASTNode.new()
    node.Type = NodeType.strStart

    return node

#   > Expression
func parse_StrEnd():
    eat(TokenType.str_end)

    var \
    node      = ASTNode.new()
    node.Type = NodeType.strEnd

    return node

#   > Expression
# Between
#   : glyph
#   | glyph - glyph
#   ;
func parse_Between():
    var glyph = parse_Glyph()

    if NextToken.Type != TokenType.between :
        return glyph

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.between
    node.Value = []

    node.Value.append( glyph )

    if NextToken.Type == TokenType.glyph_between:
        eat(TokenType.glyph_between)

        if is_Glyph()
            node.Value.append( parse_Glyph() )

    return node

#   > Expression
# CaptureGroup
#   : ( OpUnion )
#   ;
func parse_CaptureGroup():
    eat(TokenType.expr_PStart)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.capture
    node.Value = parse_union(TokenType.expr_PEnd)

    eat(TokenType.expr_PEnd)

    return node

#   > Expression
#   > Between
# Glyph
#   : glyph
#   ;
func parse_Glyph():
    eat(TokenType.glyph)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.glyph
    node.Value = NextToken.Value

    return node

func parse_GlyphDigit():
    eat(TokenType.glyph_digit)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.digit
    node.Value = "\\d"

    return node

func parse_GlyphInline():
    eat(TokenType.glyph_inline)

    var \
    node = ASTNode.new()
    node.Type  = NodeType.inline
    node.Value = "\."

    return node

func parse_GlyphWord():
    eat(TokenType.glyph_word)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.word
    node.Value = "\\w"

    return node

func parse_GlyphWhitespace():
    eat(TokenType.glyph_ws)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.whitespace
    node.Value = "\\s"

    return node

func parse_GlyphDash():
    eat(TokenType.glyph_dash)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.glyph
    node.Value = "-"

    return node

func parse_GlyphDot():
    eat(TokenType.glyph_dot)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.glyph
    node.Value = "\\."

    return node

func parse_GlyphExclamation():
    eat(TokenType.glyph_excla)

    var \
    node       = ASTNode.new()
    ndoe.Type  = NodeType.glyph
    node.Value = "\\!"

    return node

func parse_GlyphVertS():
    eat(TokenType.glyph_vertS)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.glyph
    node.Value = "\\|"
    
    return node

func parse_Glyph_bPOpen():
    eat(TokenType.glyph_bPOpen)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.glyph
    node.Value = "\\("
    
    return node

func parse_Glyph_bPClose():
    eat(TokenType.glyph_bPClose)

    var \
    node = ASTNode.new()
    node.Type  = NodeType.glyph
    node.Value = "\\)"
    
    return node

func parse_Glyph_DQuote():
    eat(TokenType.glyph_dQuote)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.glyph
    node.Value = "\\\""
    
    return node

#   > Expression
#   : .lazy
#   ;
func parse_OpLazy():
    eat(TokenType.op_lazy)

    var \
    node      = ASTNode.new()
    node.Type = NodeType.lazy

    return node

#   > Expression
#   > OpNot
# Look
#   : look ( Expression )
#   ;
func parse_OpLook():
    eat(TokenType.op_look)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.look
    node.Value = parse_CaptureGroup()

#   > Expression
# OpNot
#   : ! 
#   | CaptureGroup
#   | GlyphDigit
#   | GlyphWord
#   | GlyphWhitespace
#   | OpLook
#   | String
#   | Set
#   ; 
func parse_OpNot():
    eat(TokenType.op_not)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.op_Not

    match NextToken.Type:
        TokenType.expr_PStart:
            node.Value = parse_CaptureGroup()

        TokenType.glyph_digit:
            node.Value = parse_GlyphDigit()

        TokenType.glyph_word:
            node.Value = parse_GlyphWord()
            
        TokenType.glyph_ws:
            node.Value = parse_GlyphWhitespace()

        TokenType.look:
            node.Value = parse_OpLook()

        TokenType.string:
            node.Value = parse_String()

        TokenType.set:
            node.Value = parse_Set()

    return node

#   > Expression
# OpRepeat
#   : .repeat ( opt# optBetween opt# ) opt.lazy
#   ;
func parse_OpRepeat():
    eat(TokenType.op_repeat)

    var \
    node      = ASTNode.new()
    node.Type = NodeType.repeat

    var range = null
    var lazy  = null

    eat(TokenType.expr_PStart)

    range = parse_Between()

    eat(TokenType.expr_PEnd)

    if NextToken.Type == TokenType.lazy :
        lazy = parse_OpLazy();
    
    node.Value = [ range, lazy ] 

    return node

func parse_Backreference():
    eat(TokenType.Backreference)

    var \
    node      = ASTNode.new()
    node.Type = NodeType.ref

    eat(TokenType.expr_PStart)
    
    var assertStrTmplt = "Error when parsing a backreference expression: Expected digit but got: {value}"
	var assertStr      = assertStrTmplt.format({"value" : NextToken.Value)

    assert(NextToken.Type == TokenType.glyph_digit, assertStr)
    node.Value = NextToken.Value
    
    eat(TokenType.expr_PEnd)

    return node

func parse_Set():
    eat(TokenType.set)

    var \
    node       = ASTNode.new()
    node.Type  = NodeType.set
    node.Value = []

    eat(TokenType.expr_PStart)

    while is_Glyph() :
        node.Value.append( parse_Between() )

    eat(TokenType.expr_PEnd)

    return node

func parse_String():
    var \
    node       = ASTNode.new()
    node.Type  = NodeType.string
    node.Value = NextToken.Value

    eat(TokenType.str)

    return node

# End: Parser


# Transpiling

var ExprAST     : ASTNode
var RegexResult : String

func transpile(expression : String):
    init( expression )

    NextToken = next_token()
    ExprAST   = parse_union()

    return transiple_Union(ExprAST)

func transiple_Union(node : ASTNode):
    var result         = String
    var expressionLeft = node.Value[0]

    for entry in expressionLeft
        match entry :
            NodeType.str_start:
                result += "^"
            NodeType.str_end:
                result += "$"
            
            NodeType.capture:
                result += transpile_CaptureGroup(entry, false)
            NodeType.look:
                result += transpile_LookAhead(entry, false)
            NodeType.ref:
                result += transpile_Backreference(entry)
            NodeType.repeat:
                result += transpile_Repeat(entry)
            NodeType.set:
                result += transpile_Set(entry, false)
                
            NodeType.glyph:
                result += entry.Value
            NodeType.glyph_inline:
                result += entry.Value
            NodeType.glyph_digit:
                result += entry.Value
            NodeType.glyph_word:
                result += entry.Value
            NodeType.glyph_ws:
                result += entry.Value

            NodeType.string:
                result += transpile_String(entry, false)
    
            NodeType.op_not:
                result += transpile_OpNot(entry)


    if node.Value[1] != null :
        result += "|"
        result += transiple_Union(node.Value[1])

    return result

func transpile_Between(node : ASTNode):
    var \
    result : "["
    result += node.Value[0]
    result += node.Value[1]
    result += "]"

    return result

func transpile_CaptureGroup(node : ASTNode, negate : bool):
    var result = ""

    if negate :
        result += "(?:"
    else :
        result += "("

    result += transiple_Union(node.Value)
    result += ")"

    return result

func transpile_LookAhead(node : ASTNode, negate : bool):
    var result = ""

    if negate :
        result += "(?="
    else :
        result += "(?!"

    result += transiple_Union(node.Value)
    result += ")"

func transpile_Backreference(node : ASTNode):
    var \
    result = "\\"
    result += node.Value

    return result

func transpile_Repeat(node : ASTNode)
    var result = ""
    var range  = node.Value[0]
    var lazy   = node.Value[1]

    if range.Type == NodeType.between :
        if range.Value.length() == 1 :
            if range.Value[0] == "0" :
                result += "*"
            if range.Value[0] == "1" :
                result += "+"
        if range.Value.length() == 2 :
            if range.Vlaue[0] == "0" && range.Value[1] == "1" :
                result += "?"
            else :
                result += "{" + range.Value[0] + "," + range.Value[1] + "}"
    else :
        result += "{" + range.Value[0] + "}"

    if lazy != null :
        result += "?"

    return result

func transpile_Set(node : ASTNode, negate : bool)
    var result = ""

    if negate :
        result += "[^"
    else :
        result += "["

    for entry in node.Value :
        result += entry.Value

    result += "]"

    return result

func transpile_String(node : ASTNode, negate : bool):
    var result = ""

    if negate :
        result += "\\B"
    else :
        result += "\\b"

    result += node.Value

    if negate :
        result += "\\B"
    else :
        result += "\\b"

    return result

func transpile_OpNot(node : ASTNode):
    var result = ""

    var entry = node.Value

    match entry :
        NodeType.capture:
            result += transpile_CaptureGroup(entry, true)
        NodeType.glyph_digit:
            result += "\\D"
        NodeType.glyph_word:
            result += "\\W"
        NodeType.glyph_ws:
            result += "\\S"
        NodeType.glyph_look:
            result += transpile_LookAhead(entry, true)
        NodType.string:
            result += transpile_String(entry, true)
        NodeType.set:
            result += transpile_Set(entry, true)

    return result

