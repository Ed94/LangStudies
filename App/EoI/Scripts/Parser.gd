extends Object

# ---------------------------------------------------------- UTILITIES
var ErrorOut

func check( condition : bool, message : String):
	assert(condition, message)
	if ! condition:
		ErrorOut.text = "Eva - Error: " + message

func throw( message ):
	assert(false, message)
	ErrorOut.text = "Eva - Error: " + message
# ---------------------------------------------------------- UTILITIES END

class_name Parser

# ---------------------------------------------------------- AST Node

const NType = \
{
	program = "Program",
	
	empty = "Empty",
	
	block = "Scope Block",

	conditional = "Conditional",
	expr_While  = "Expression While",

	literal_Number = "Literal: Number",
	literal_String = "Literal: String",
	
	op_Assign = "Assignment",
	op_Fn     = "Function Call",
	
	op_Add     = "+",
	op_Sub     = "-",
	op_Mult    = "*",
	op_Div     = "/",
	
	op_Greater      = ">",
	op_GreaterEqual = ">=",
	op_Lesser       = "<",
	op_LesserEqual  = "<=",
	
	fn_Print  = "Print",
	fn_User   = "User Function",
	fn_Lambda = "Lambda Function",
	fn_IIL    = "Lambda Function Immediate Invocation",
	fn_Params = "Function Parameters",
	fn_Body   = "Function Body",

	identifier = "Identifier",
	variable   = "Variable"
}

class ASTNode:
	var Data : Array
	
	func get_class() :
		return "ASTNode"
	
	
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
		
	func is_op_Numeric():
		match type():
			NType.op_Add: return true
			NType.op_Sub: return true
			NType.op_Mult: return true
			NType.op_Div: return true
			_: return false
		
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
				if entry.get_class() ==  "Eva":
					result.append(entry)
				else:
					fn_objSerializer.set_instance(entry)
					result.append( fn_objSerializer.call_func() )

			else :
				result.append( entry )
				
		return result

	func to_SExpression():
		var \
		to_SExpression_Fn = FuncRef.new()
		to_SExpression_Fn.set_function("to_SExpression")
		
		return array_Serialize( self.Data, to_SExpression_Fn )
	# Serialization END -------------------------------------------------

# ---------------------------------------------------------- AST Node END

const SLexer = preload("Lexer.gd")
const TType  = SLexer.TType
var   Lexer  : SLexer

var NextToken : SLexer.Token

# Gets the next token only if the current token is the specified intended token (tokenType)
func eat(tokenType):
	var currToken = NextToken
	
	check(currToken != null, "Parser - eat: NextToken was null")
	
	var assertStrTmplt = "Parser - eat: Unexpected token: {value}, expected: {type}"
	var assertStr      = assertStrTmplt.format({"value" : currToken.Value, "type" : tokenType})
	
	check(currToken.Type == tokenType, assertStr)
	
	NextToken = Lexer.next_Token()
	
	return currToken

func parse():
	var \
	node = ASTNode.new()
	node.set_Type(NType.program)
		
	while NextToken != null :
		if NextToken.Type == TType.def_Start:
			node.add_Expr( parse_Expression() )
		
		elif NextToken.Type == TType.identifier:
			node.add_Expr( parse_Identifier() )
	
		elif NextToken.is_Literal():
			node.add_Expr( parse_Literal() )
	
	return node
	
func parse_Expression():
	eat(TType.def_Start)
	var node : ASTNode
	
	match NextToken.Type :
		TType.def_Block:
			node = parse_Block()
		TType.def_Cond:
			node = parse_ConditionalIf()
		TType.def_While:
			node = parse_While()
		TType.def_Var:
			node = parse_Variable()
		TType.def_Func:
			node = parse_fn_User()
		TType.def_Lambda:
			node = parse_fn_Lambda()
		TType.fn_Print:
			node = parse_fn_Print()
		TType.op_Assgin:
			node = parse_op_Assign()
		TType.op_Numeric:
			node = parse_op_Numeric()
		TType.op_Relational:
			node = parse_op_Relational()
		TType.identifier:
			node = parse_op_Fn()
		TType.def_Start:
			node = parse_fn_IIL()
	
	var arg = 1
	while NextToken.Type != TType.def_End:
		if NextToken.Type == TType.def_Start:
			node.add_Expr( parse_Expression() ) 
		elif NextToken.Type == TType.identifier:
			node.add_Expr( parse_Identifier() )
		else :	
			node.add_Expr( parse_Literal() )
		
	eat(TType.def_End)
	
	if node == null:
		node = ASTNode.new()
		node.set_Type(NType.empty)
	
	return node

func parse_Block():
	var \
	node = ASTNode.new()
	node.set_Type(NType.block)
	eat(TType.def_Block)

	return node
	
func parse_ConditionalIf():
	var \
	node = ASTNode.new()
	node.set_Type(NType.conditional)
	eat(TType.def_Cond)
	return node
	
func parse_While():
	var \
	node = ASTNode.new()
	node.set_Type(NType.expr_While)
	eat(TType.def_While)
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
		
	return node
	
func parse_fn_User():
	var \
	node = ASTNode.new()
	node.set_Type(NType.fn_User)
	eat(TType.def_Func)
	
	check( NextToken.Type == TType.identifier,
		String("Parser - parse_op_Assign: NextToken should have been identifier, Type: {type} Value: {value}") \
		.format({"type" : NextToken.Type, "value" : NextToken.Value })
	)
	
	node.add_TokenValue( NextToken )
	eat(TType.identifier)
	
	# Parameters
	var \
	pNode = ASTNode.new()
	pNode.set_Type(NType.fn_Params)
	eat(TType.def_Start)
	
	while NextToken.Type != TType.def_End:
		check( NextToken.Type == TType.identifier,
			String("Parser - parse_op_Assign: NextToken should have been identifier, Type: {type} Value: {value}") \
			.format({"type" : NextToken.Type, "value" : NextToken.Value })
		)
		
		pNode.add_TokenValue(NextToken)
		eat(TType.identifier)
		
	eat(TType.def_End)
	
	var \
	bNode = ASTNode.new()
	bNode.set_Type(NType.fn_Body)
	
	while NextToken.Type != TType.def_End:
		bNode.add_Expr( parse_Expression() )
	
	node.add_Expr( pNode )
	node.add_Expr( bNode )
	
	return node
	
func parse_fn_Lambda():
	var \
	node = ASTNode.new()
	node.set_Type(NType.fn_Lambda)
	eat(TType.def_Lambda)
	
	# Parameters
	var \
	pNode = ASTNode.new()
	pNode.set_Type(NType.fn_Params)
	eat(TType.def_Start)
	
	while NextToken.Type != TType.def_End:
		check( NextToken.Type == TType.identifier,
			String("Parser - parse_op_Assign: NextToken should have been identifier, Type: {type} Value: {value}") \
			.format({"type" : NextToken.Type, "value" : NextToken.Value })
		)
		
		pNode.add_TokenValue(NextToken)
		eat(TType.identifier)
		
	eat(TType.def_End)
	
	var \
	bNode = ASTNode.new()
	bNode.set_Type(NType.fn_Body)
	
	while NextToken.Type != TType.def_End:
		bNode.add_Expr( parse_Expression() )
	
	node.add_Expr( pNode )
	node.add_Expr( bNode )
		
	return node
	
func parse_fn_IIL():
	var \
	node = ASTNode.new()
	node.set_Type(NType.fn_IIL)
	
	# Lambda
	node.add_Expr( parse_Expression() )
	
	return node

func parse_Identifier():
	var \
	node = ASTNode.new()
	node.set_Type(NType.identifier)
	node.add_TokenValue(NextToken)
	
	eat(TType.identifier)
	
	return node
	
func parse_fn_Print():
	var \
	node = ASTNode.new()
	node.set_Type(NType.fn_Print)
	
	eat(TType.fn_Print)
	
	return node
	
func parse_op_Assign():
	var \
	node = ASTNode.new()
	node.set_Type(NType.op_Assign)
	
	eat(TType.op_Assgin)
	
	check( NextToken.Type == TType.identifier,
		String("Parser - parse_op_Assign: NextToken should have been identifier, Type: {type} Value: {value}") \
		.format({"type" : NextToken.Type, "value" : NextToken.Value })
	)
		
	node.add_TokenValue( NextToken )
	eat(TType.identifier)

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
	
func parse_op_Relational():
	var node = ASTNode.new()

	match NextToken.Value:
		NType.op_Greater:
			node.set_Type(NType.op_Greater)
		NType.op_Lesser:
			node.set_Type(NType.op_Lesser)
		NType.op_GreaterEqual:
			node.set_Type(NType.op_GreaterEqual)
		NType.op_LesserEqual:
			node.set_Type(NType.op_LesserEqual)

	eat(TType.op_Relational)

	return node
	
func parse_op_Fn():
	var \
	node = ASTNode.new()
	node.set_Type(NType.op_Fn)
	node.add_TokenValue( NextToken )
	eat(TType.identifier)
	
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
	
func _init(lexer, errorOut) :
	ErrorOut = errorOut
	Lexer    = lexer
	
	NextToken = Lexer.next_Token()
	
