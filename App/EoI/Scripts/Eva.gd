extends Object

var SRegEx = preload("res://RegM/Scripts/SRegex.gd").new()

# ---------------------------------------------------------- Lexer
const TType : Dictionary = \
{
	fmt_S  = "Formatting",
	cmt_SL = "Comment Single-Line",
	cmt_ML = "Comment Multi-Line",
	
	def_Start = "Expression Start",
	def_End   = "Expression End",
	def_Var   = "Variable",
	
	literal_Number = "Literal: Number",
	literal_String = "Literal: String",
	
	op_Assgin = "Assignment",
	op_Numeric = "op_Numeric",
	
	identifier = "Identifier"
}

const Spec : Dictionary = \
{
	TType.cmt_SL : "start // inline.repeat(0-)",
	TType.cmt_ML : "start /* set(whitespace !whitespace).repeat(0-).lazy */",
	
	TType.fmt_S : "start whitespace.repeat(1-).lazy",
	
	TType.def_Start : "start \\(",
	TType.def_End   : "start \\)",
	TType.def_Var   : "start \"var\"",
	
	TType.literal_Number : \
	"""start 
		set(+ \\-).repeat(0-1)	
		( set(0-9).repeat(1-) \\. ).repeat(0-1) 
		set(0-9).repeat(1-) 
	""",
	TType.literal_String : "start \\\" !set( \\\" ).repeat(0-) \\\" ",
	
	TType.op_Assgin  : "start \"set\"",
	TType.op_Numeric : "start set(+ \\- * /)",
	
	TType.identifier : 
	"""start 
	(
		set(A-z).repeat(1-) 
		set(\\- _).repeat(0-1)
	)
	.repeat(0-1)
	"""
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
		var regex  = RegEx.new()
		var result = SRegEx.compile(Spec[type])
		
		regex.compile( result )
		
		SpecRegex[type] = regex

func init(programSrcText, errorOutput):
	ErrorOutput = errorOutput
	
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
			var assertStrTmplt = "Lexer - tokenize: Source text not understood by tokenizer at Cursor pos: {value} -: {txt}"
			var assertStr      = assertStrTmplt.format({"value" : Cursor, "txt" : srcLeft})
			throw(assertStr)
			return
# ---------------------------------------------------------- Lexer END


# ---------------------------------------------------------- Parser
# ---------------------------------------------------------- AST Node

const NType = \
{
	literal_Number = "Literal: Number",
	literal_String = "Literal: String",
	
	op_Assign = "Assignment",
	
	op_Add  = "+",
	op_Sub  = "-",
	op_Mult = "*",
	op_Div  = "/",

	identifier = "Identifier",
	variable = "Variable"
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
	
	check(currToken != null, "Parser - eat: NextToken was null")
	
	var assertStrTmplt = "Parser - eat: Unexpected token: {value}, expected: {type}"
	var assertStr      = assertStrTmplt.format({"value" : currToken.Value, "type" : tokenType})
	
	check(currToken.Type == tokenType, assertStr)
	
	NextToken = next_Token()
	
	return currToken

func parse():
	NextToken = next_Token()
	
	if NextToken.Type == TType.def_Start:
		return parse_Expression()
		
	if NextToken.Type == TType.identifier:
		return parse_Identifier()
	
	if NextToken.is_Literal():
		return parse_Literal()
	
func parse_Expression():
	eat(TType.def_Start)
	var node : ASTNode
	
	if NextToken.Type == TType.def_Var:
		node = parse_Variable()
	
	if NextToken.Type == TType.op_Assgin:
		node = parse_op_Assign()
	
	elif NextToken.Type == TType.op_Numeric:
		node = parse_op_Numeric()
		
		var arg = 1
		while NextToken.Type != TType.def_End:
			if NextToken.Type == TType.def_Start:
				node.add_Expr( parse_Expression() ) 
			else :	
				node.add_Expr( parse_Literal() )
	
	elif NextToken.is_Literal():
		node = parse_Literal()
	
	eat(TType.def_End)
	
	return node
	
func parse_Variable():
	var \
	node = ASTNode.new()
	node.set_Type(NType.variable)
	eat(TType.def_Var)
	
	check( NextToken.Type == TType.identifier,
		String("Parser - parse_Variable: NextToken should have been identifier. TokenData - Type: {type} Value: {value}") \
		.format({"type" : NextToken.Type, "value" : NextToken.Value })
	)
	
	node.add_TokenValue( NextToken )
	eat(TType.identifier)
	
	if NextToken.Type == TType.def_Start :
		node.add_Expr( parse_Expression() )
		
	else :
		node.add_Expr( parse_Literal() )
		
	return node
	
func parse_Identifier():
	var \
	node = ASTNode.new()
	node.set_Type(NType.identifier)
	node.add_TokenValue(NextToken)
	
	eat(TType.identifier)
	
	return node
	
func parse_op_Assign():
	var \
	node = ASTNode.new()
	node.set_type(NType.op_Assign)
	
	eat(TType.op_Assgin)
	
	check( NextToken.Type != TType.identifier,
		String("Parser - parse_op_Assign: NextToken should have been identifier, Type: {type} Value: {value}") \
		.format({"type" : NextToken.Type, "value" : NextToken.Value })
	)
		
	node.add_TokenValue( NextToken.Value )

	if NextToken.is_Literal() :
		node.add_Expr( parse_Literal() )

	elif NextToken.Type == TType.def_Start :
		node.add_Expr( parse_Expression() )

	return node
	
func parse_op_Numeric():
	var node = ASTNode.new()
	
	match NextToken.Value:
		NType.op_Add:
			node.set_Type(NType.op_Add)
		NType.op_Sub:
			node.set_Type(NType.op_Sub)
		NType.op_Mult:
			node.set_Type(NType.op_Mult)
		NType.op_Div:
			node.set_Type(NType.op_Div)
			
	eat(TType.op_Numeric)
	
	return node
	
func parse_Literal():
	var node = ASTNode.new()
	
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

# ---------------------------------------------------------- Environment

var Records : Dictionary

func env_DefineVar(symbol : String, value) :
	Records[symbol] = value
	
func env_Lookup(symbol : String) :
	check(Records.has(symbol), String("Symbol not found in environment records"))
	
	return Records[symbol]

# ---------------------------------------------------------- Environment END

class_name Eva

# ---------------------------------------------------------- GLOBALS
var ErrorOutput
# ---------------------------------------------------------- GLOBALS END

# ---------------------------------------------------------- UTILITIES
func check( condition : bool, message : String):
	assert(condition, message)
	ErrorOutput.text = "Eva - Error: " + message

func throw( message ):
	assert(false, message)
	ErrorOutput.text = "Eva - Error: " + message
# ---------------------------------------------------------- UTILITIES END

func eval( ast ):
	if ast.type() == NType.identifier :
		return env_Lookup( ast.arg(1) )
	
	if ast.type() == NType.variable :
		var symbol = ast.arg(1)
		var value  = eval( ast.arg(2) )

		env_DefineVar(symbol, value)
		return value
		
	if ast.is_String() : 
		return ast.string()

	return String( eval_Numeric(ast) )
	
	var msgT = "eval - Unimplemented: {ast}"
	var msg  = msgT.format({"ast" : JSON.print(ast.to_SExpression(), "\t") })
	throw(msg)

func eval_Numeric( ast ):
	if ast.is_Number() : 	
		return float(ast.arg(1))	
	
	if ast.type() == NType.op_Add:
		var result  = 0.0; var index = 1
		
		while index <= ast.num_args():
			result += eval_Numeric( ast.arg(index) )
			index  += 1
			
		return result
		
	if ast.type() == NType.op_Sub:
		var result = 0.0; var index = 1
		
		while index <= ast.num_args():
			result -= eval_Numeric( ast.arg(index) )
			index  += 1
			
		return result
		
	if ast.type() == NType.op_Mult:
		var result = 1.0; var index = 1
		
		while index <= ast.num_args():
			result *= eval_Numeric( ast.arg(index) )
			index  += 1
			
		return result
			
	if ast.type() == NType.op_Div:
		var result = 1.0; var index = 1
		
		while index <= ast.num_args():
			result /= eval_Numeric( ast.arg(index) )
			result += 1
			
		return result
	
