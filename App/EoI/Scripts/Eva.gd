extends Object

var SRegEx = preload("res://RegM/Scripts/SRegex.gd").new()


const TType : Dictionary = \
{
	fmt_S = "Formatting",
	cmt_SL = "Comment Single-Line",
	cmt_ML = "Comment Multi-Line",
	
	def_Start = "Expression Start",
	def_End   = "Expression End",
	
	literal_Number = "LIteral: Number",
	literal_String = "Literal: String",
	
	operator = "Operator"
}

const Spec : Dictionary = \
{
	TType.cmt_SL : "start // inline.repeat(0-)",
	TType.cmt_ML : "start /* set(whitespace !whitespace).repeat(0-).lazy */",
	
	TType.fmt_S : "start whitespace.repeat(1-).lazy",
	
	TType.def_Start : "start \\(",
	TType.def_End : "start \\)",
	
	TType.literal_Number : \
	"""start 
		set(+ \\-).repeat(0-1)
		( set(0-9).repeat(1-) \\. ).repeat(0-1) 
		set(0-9).repeat(1-) 
	""",
	TType.literal_String : "start \\\" !set( \\\" ).repeat(0-) \\\" ",
	
	TType.operator : "start set(+ \\-)",
}

class Token:
	var Type  : String
	var Value : String
	
	func is_Literal():
		return Type == TType.literal_Number || Type == TType.literal_String;


var SourceText : String
var Cursor     : int
var SpecRegex  : Dictionary
var Tokens     : Array
var TokenIndex : int = 0


func compile_regex():
	for type in TType.values() :
		var \
		regex = RegEx.new()
		regex.compile( SRegEx.transpile(Spec[type]) )
		
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
		for type in TType.values() :
			var result = SpecRegex[type].search( srcLeft )
			if  result == null || result.get_start() != 0 :
				continue

			# Skip Comments
			if type == TType.cmt_SL || type == TType.cmt_ML :
				Cursor += result.get_string().length()
				error   = false
				break
				
			# Skip Whitespace
			if type == TType.fmt_S :
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
# ---------------------------------------------------------- Lexer


# ---------------------------------------------------------- Parser
# ---------------------------------------------------------- AST Node

const NType = \
{
	literal_Number = "Literal: Number",
	literal_String = "Literal: String",
	
	op_Add  = "+",
	op_Mult = "*"
}

class ASTNode:
	var Data : Array
	
	func add_Expr( expr ):
		Data.append(expr)
		
	func add_TokenValue( token ):
		Data.append( token.Value )	
	
	func set_Type( nType ):
		Data.append(nType)
		
	func arg( id ):
		return Data[id]
		
	func num_args():
		return Data.size() - 1
	
	func type():
		return Data[0]
		
	func is_Number():
		return type() == NType.literal_Number
		
	func is_String():
		return type() == NType.literal_String
		
	func string():
		return arg(1).substr(1, arg(1).length() -2)
		
	
	# Serialization ----------------------------------------------------
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
		# var expression = []
		
		# if typeof(Value) == TYPE_ARRAY :
		var \
		to_SExpression_Fn = FuncRef.new()
		to_SExpression_Fn.set_function("to_SExpression")
		
		return array_Serialize( self.Data, to_SExpression_Fn )
			
		# if typeof(Value) == TYPE_OBJECT :
		# 	var result = [ Type, Value.to_SExpression() ]
		# 	return result
			
		# expression.append(Value)
		# return expression
	# Serialization END -------------------------------------------------

# ---------------------------------------------------------- AST Node END

var TokenType : Token
var NextToken : Token

# Gets the next token only if the current token is the specified intended token (tokenType)
func eat(tokenType):
	var currToken = NextToken
	
	assert(currToken != null, "eat: NextToken was null")
	
	var assertStrTmplt = "eat: Unexpected token: {value}, expected: {type}"
	var assertStr      = assertStrTmplt.format({"value" : currToken.Value, "type" : tokenType})
	
	assert(currToken.Type == tokenType, assertStr)
	
	NextToken = next_Token()
	
	return currToken

func parse():
	NextToken = next_Token()
	
	if NextToken.Type == TType.def_Start:
		return parse_Expression()
	
	if NextToken.is_Literal():
		return parse_Literal()
	
func parse_Expression():
	eat(TType.def_Start)
	var node : ASTNode
	
	if NextToken.Type == TType.operator:
		node = parse_Operator()
		
		var arg = 1
		while NextToken.Type != TType.def_End:
			node.add_Expr( parse_Literal() )
	
	if NextToken.is_Literal():
		node = parse_Literal()
	
	eat(TType.def_End)
	
	return node

func parse_Operator():
	var \
	node = ASTNode.new()
	
	match NextToken.Value:
		NType.op_Add:
			node.set_Type(NType.op_Add)
		NType.op_Mult:
			node.set_Type(NType.op_Mult)
			
	eat(TType.operator)
	
	return node
	
func parse_Literal():
	var \
	node = ASTNode.new()
	
	match NextToken.Type:
		TType.literal_Number:
			node.set_Type(NType.literal_Number)
			node.add_TokenValue(NextToken)
			
			eat(TType.literal_Number)
			
		TType.literal_String:
			node.set_Type(NType.literal_String)
			node.add_TokenValue(NextToken)
			
			eat(TType.literal_String)
	
	return node

# ---------------------------------------------------------- Parser END

class_name Eva

# ---------------------------------------------------------- GLOBALS

# ---------------------------------------------------------- GLOBALS END

# ---------------------------------------------------------- UTILITIES

func throw( message ):
	assert(false, message)
# ---------------------------------------------------------- UTILITIES END

func eval( ast ):
	if ast.is_Number() : 	
		return float(ast.arg(1))
	if ast.is_String() : 
		return ast.string()
	
	if ast.type() == NType.op_Add:
		return String(eval( ast.arg(1) ) + eval( ast.arg(2) ))
		
	if ast.type() == NType.op_Mult:
		return String(eval( ast.arg(1) ) * eval( ast.arg(2) ))

	throw("Unimplemented")
