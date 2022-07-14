extends Object

const NodeType = \
{
	program = "Program",
	
	expr_Assignment     = "Assignment Expression",
	expr_Call           = "Call Expression",
	expr_ClassExtend    = "Class Extension",
	expr_Binary         = "Binary Expression",
	expr_Logical        = "Logical Expression",
	expr_Member         = "Member Expression",
	expr_New            = "New Expression",
	expr_Super          = "Super Expression",
	expr_This           = "This Expression",
	expr_Unary          = "Unary Expression",

	def_Class     = "Class Declaration",
	def_Procedure = "Function Declaration",
	def_Variable  = "Variable Declaration",

	literal_Bool    = "Boolean Literal",
	literal_Numeric = "Numeric Literal",
	literal_String  = "String Literal",
	literal_Null    = "Null Literal",

	stmt_Block       = "Block Statement",
	stmt_Conditional = "Conditional Statement",
	stmt_Expression  = "Expression Statement",
	stmt_Empty       = "Empty Statement",
	stmt_Variable    = "Variable Statement",
	stmt_While       = "While Statement",
	stmt_DoWhile     = "Do-While Statement",
	stmt_For         = "For Statement",
	stmt_Return      = "Return Statement",

	sym_Identifier = "Identifier"
}

class PNode:
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



var SLexer    : Script = preload("res://RDP/Scripts/Lexer.gd")
var TokenType = SLexer.TokenType
var NextToken : Lexer.Token
var Lexer



# --------------------------------------------------------------------- HELPERS

# Gets the next token only if the current token is the specified intended token (tokenType)
func eat(tokenType):
	var currToken = NextToken
	
	assert(currToken != null, "eat: NextToken was null")
	
	var assertStrTmplt = "eat: Unexpected token: {value}, expected: {type}"
	var assertStr      = assertStrTmplt.format({"value" : currToken.Value, "type" : tokenType})
	
	assert(currToken.Type == tokenType, assertStr)
	
	NextToken = Lexer.next_Token()
	
	return currToken

func is_Literal():
	return \
	   NextToken.Type == TokenType.literal_Number \
	|| NextToken.Type == TokenType.literal_String \
	|| NextToken.Type == TokenType.literal_BTrue  \
	|| NextToken.Type == TokenType.literal_BFalse \
	|| NextToken.Type == TokenType.literal_Null

# BinaryExpression
#	: MultiplicativeExpression
#	| AdditiveExpression
#	;
func parse_BinaryExpression(parse_fn, operatorToken):
	var left = parse_fn.call_func()
	
	while NextToken.Type == operatorToken:
		var operator = eat(operatorToken)
		var right    = parse_fn.call_func()

		var \
		nestedNode       = PNode.new()
		nestedNode.Type  = NodeType.expr_Binary
		nestedNode.Value = []
		nestedNode.Value.append(operator.Value)
		nestedNode.Value.append(left)
		nestedNode.Value.append(right)

		left = nestedNode;
	
	return left

# LogicalExpression
#	: LogicalAndExpression
#	| LogicalOrExpression
#	;
func parse_LogicalExpression(parse_fn, operatorToken):
	var left = parse_fn.call_func()

	while NextToken.Type == operatorToken :
		var operator = eat(operatorToken).Value
		var right    = parse_fn.call_func()

		var \
		nestedNode       = PNode.new()
		nestedNode.Type  = NodeType.expr_Logical
		nestedNode.Value = []
		nestedNode.Value.append(operator)
		nestedNode.Value.append(left)
		nestedNode.Value.append(right)

		left = nestedNode

	return left

# ------------------------------------------------------------------ END HELPERS

# Parses the text program description into an AST.
func parse(lexer):
	Lexer     = lexer
	NextToken = lexer.next_Token()
	
	return parse_Program()

#	> parse 
# Program
#	: StatementList
# 	: Literal
#	;
func parse_Program():
	var \
	node       = PNode.new()
	node.Type  = NodeType.program
	node.Value = parse_StatementList(null)
	
	if node.Value == [ null ] :
		print("WTF")
	
	return node

#	> Program
#	> BlockStatement
# StatementList
#	: Statement
#	| StatementList Statement -> Statement ...
#	;
func parse_StatementList(endToken):
	var statementList = [ parse_Statement() ]
	
	while NextToken != null && NextToken.Type != endToken :
		statementList.append( parse_Statement() )
		
	return statementList
	
#	> StatementList
#	> If_Statement
#	> WhileStatement
# Statement
# 	: ExpressionStatement
#	| BlockStatement
#	| EmptyStatement
#	| VariableStatement
#   | If_Statement
#	| IterationStatement
#	| FunctionDeclaration
#	| ReturnStatement
#	| ClassDeclaration
#	;
func parse_Statement():
	if NextToken == null :
		return null
	
	match NextToken.Type :
		TokenType.def_If :
			return parse_If_Statement()
		TokenType.def_End :
			return parse_EmptyStatement()
		TokenType.def_BStart :
			return parse_BlockStatement()
		TokenType.def_Var :
			return parse_VariableStatement()
		TokenType.def_While :
			return parse_IterationStatement()
		TokenType.def_Do :
			return parse_IterationStatement()
		TokenType.def_For :
			return parse_IterationStatement()
		TokenType.def_Proc:
			return parse_FunctionDeclaration()
		TokenType.def_Return:
			return parse_ReturnStatement()
		TokenType.def_Class:
			return parse_ClassDeclaration()

	return parse_ExpressionStatement()

# If Statement
#	: if ( Expression ) Statement
#	| if ( Expression ) Statement else Statement
#	;
func parse_If_Statement():
	eat(TokenType.def_If)

	eat(TokenType.expr_PStart)
	var condition = parse_Expression()
	eat(TokenType.expr_PEnd)

	var consequent  = parse_Statement()
	var alternative = null
	
	if NextToken != null && NextToken.Type == TokenType.def_Else :
		eat(TokenType.def_Else)
		alternative = parse_Statement()

	var \
	node       = PNode.new()
	node.Type  = NodeType.stmt_Conditional
	node.Value = [ condition, consequent, alternative ]

	return node

#	> Statement
# EmptyStatement
#	;
func parse_EmptyStatement():
	eat(TokenType.def_End)

	var \
	node      = PNode.new()
	node.Type = NodeType.stmt_Empty
	
	return node

#	> Statement
# BlockStatement
#	: { OptStatementList }
#	;
func parse_BlockStatement():
	eat(TokenType.def_BStart)

	var \
	node      = PNode.new()
	node.Type = NodeType.stmt_Block

	if NextToken.Type != TokenType.def_BEnd :
		node.Value = parse_StatementList(TokenType.def_BEnd)
	else :
		node.Value = []

	eat(TokenType.def_BEnd)

	return node

#	> Statement
# VariableStatement
#	: VariableStatementInit StatementEnd
#	;
func parse_VariableStatement():
	var varStatement = parse_VariableStatementInit()

	eat(TokenType.def_End)

	return varStatement

#	> VariableStatement
# VariableStatementInit
#	: VarDeclare VariableDeclarationList
#	;
func parse_VariableStatementInit():
	eat(TokenType.def_Var)
	
	var declarations = parse_VariableDeclarationList()

	var \
	node       = PNode.new()
	node.Type  = NodeType.stmt_Variable
	node.Value = declarations

	return node

#	> Statement
# IterationStatement
#	: WhileStatement
#	| DoWhileStatement
#	| ForStatement
#	;
func parse_IterationStatement():
	match NextToken.Type:
		TokenType.def_While :
			return parse_WhileStatement()
		TokenType.def_Do :
			return parse_DoWhileStatement()
		TokenType.def_For :
			return parse_ForStatement()

#	> IterationStatement
# WhileStatement
#	: while ( Expression ) Statement
#	;
func parse_WhileStatement():
	eat(TokenType.def_While)	

	eat(TokenType.expr_PStart)
	var condition = parse_Expression()
	eat(TokenType.expr_PEnd)

	var body = parse_Statement()
	var \
	node       = PNode.new()
	node.Type  = NodeType.stmt_While
	node.Value = [ condition, body ]

	return node

#	> IterationStatement
# DoWhileStatement
#	: do Statement while ( Expression )
#	;
func parse_DoWhileStatement():
	eat(TokenType.def_Do)

	var body = parse_Statement()

	eat(TokenType.def_While)

	eat(TokenType.expr_PStart)
	var condition = parse_Expression()
	eat(TokenType.expr_PEnd)

	eat(TokenType.def_End)

	var \
	node       = PNode.new()
	node.Type  = NodeType.stmt_DoWhile
	node.Value = [ condition, body ]

	return node

#	> IterationStatement
# ForStatement
#	: for ( 
#		OptForStatementInit ;
#		OptExpression ;
#		OptExpression
#	 )
#		Statement
#	;
func parse_ForStatement():
	eat(TokenType.def_For)

	eat(TokenType.expr_PStart)

	var init        = null
	var condition   = null
	var update      = null

	if NextToken.Type != TokenType.def_End :
		init = parse_ForStatementInit()
	eat(TokenType.def_End)

	if NextToken.Type != TokenType.def_End :
		condition = parse_Expression()
	eat(TokenType.def_End)

	if NextToken.Type != TokenType.expr_PEnd :
		update = parse_Expression()

	eat(TokenType.expr_PEnd)

	var body = parse_Statement()

	var \
	node       = PNode.new()
	node.Type  = NodeType.stmt_For
	node.Value = [ init, condition, update, body ]

	return node

#	> ForStatement
# ForStatementInit
#	: VariableStatemetnInit
#	| Expression
#	;
func parse_ForStatementInit():
	if NextToken.Type == TokenType.def_Var :
		return parse_VariableStatementInit()

	return parse_Expression()

#	> Statement
# FunctionDeclaration
#	: FuncDeclare ( OptFomralParameterList ) BlockStatement
#	;
func parse_FunctionDeclaration():

	eat(TokenType.def_Proc)

	var name = parse_Identifier()

	eat(TokenType.expr_PStart)

	var params
	if NextToken.Type != TokenType.expr_PEnd :
		params = parse_FormalParameterList()
	else :
		params = []

	eat(TokenType.expr_PEnd)

	var body = parse_BlockStatement()

	var \
	node       = PNode.new()
	node.Type  = NodeType.def_Procedure
	node.Value = [ name, params, body ]

	return node

#	> FunctionDeclaration
# FormalParameterList
#	: Identifier
#	| FormalParameterList , Identifier
#	;
func parse_FormalParameterList():
	var params = [ parse_Identifier() ]

	while NextToken.Type == TokenType.delim_Comma :
		eat(TokenType.delim_Comma)
		params.append(parse_Identifier())

	return params

#	> Statement
# ReturnStatement
#	: return OptExpression
#	;
func parse_ReturnStatement():
	eat(TokenType.def_Return)

	var argument = null
	if NextToken.Type != TokenType.def_End :
		argument = parse_Expression()
		
	eat(TokenType.def_End)

	var \
	node       = PNode.new()
	node.Type  = NodeType.stmt_Return
	node.Value = argument

	return node

#	> Statement
# ClassDeclaration
#	: class Identifier OptClassExtends BLockStatement
#	;
func parse_ClassDeclaration():
	eat(TokenType.def_Class)

	var identifier = parse_Identifier()
	var superClass = null

	if NextToken.Type == TokenType.expr_Extends :
		superClass = parse_ClassExtension()

	var body = parse_BlockStatement()

	var \
	node       = PNode.new()
	node.Type  = NodeType.def_Class
	node.Value = [ identifier, superClass, body ]

	return node

#	> ClassDeclaration
# ClassExtension
#	: extends Identifier
#	;
func parse_ClassExtension():
	eat(TokenType.expr_Extends)

	return parse_Identifier()

#	> Statement
# ExpressionStatement
#	: Expression
#	;
func parse_ExpressionStatement():
	var expression = parse_Expression()
	eat(TokenType.def_End)
	
	var \
	node       = PNode.new()
	node.Type  = NodeType.stmt_Expression
	node.Value = expression
	
	return expression

#	> ExpressionStatement
#	> If_Statement
#	> WhileStatement
#	> PrimaryExpression
# Expression
#	: AssignmentExpression
#	;
func parse_Expression():
	return parse_AssignmentExpression()

#	> VariableStatement
# VariableDeclarationList
#	: VariableDeclaration
#	| VariableDelcarationList , VariableDeclaration -> VariableDelcaration , ...
func parse_VariableDeclarationList():
	var \
	declarations = []
	declarations.append(parse_VariableDeclaration())

	while NextToken.Type == TokenType.delim_Comma :
		eat(TokenType.delim_Comma)
		declarations.append(parse_VariableDeclaration())		

	return declarations

#	> VariableDeclarationList
# VariableDeclaration
#	: Identifier OptVariableInitalizer
#	;
func parse_VariableDeclaration():
	var identifier = parse_Identifier()
	var initalizer
	if     NextToken.Type != TokenType.def_End \
		&& NextToken.Type != TokenType.delim_Comma :
		initalizer = parse_VariableInitializer()
	else :
		initalizer = null

	var \
	node       = PNode.new()
	node.Type  = NodeType.def_Variable
	node.Value = [ identifier, initalizer ]

	return node

#	> VariableDeclaration
# VariableInitializer
#	: Assignment AssignmentExpression
#	;
func parse_VariableInitializer():
	eat(TokenType.op_Assign)

	return parse_AssignmentExpression()
	
#	> Expression
#	> VariableInitializer
#	> AssignmentExpression
# AssignmentExpression
#	: RelationalExpression
#	| ResolvedSymbol AssignmentOperator AssignmetnExpression 
#	;
func parse_AssignmentExpression():
	var left = parse_LogicalOrExpression()

	if     NextToken.Type != TokenType.op_Assign \
		&& NextToken.Type != TokenType.op_CAssign :
		return left

	var assignmentOp;

	if NextToken.Type == TokenType.op_Assign :
		assignmentOp = eat(TokenType.op_Assign)
	elif NextToken.Type == TokenType.op_CAssign :
		assignmentOp = eat(TokenType.op_CAssign)

	var \
	node       = PNode.new()
	node.Type  = NodeType.expr_Assignment
	node.Value = \
	[ 
		assignmentOp.Value, 
		left,
		parse_AssignmentExpression()
	]

	return node

#	> VariableDeclaration
#	> ParenthesizedExpression
# Identifier
#	: IdentifierSymbol
#	;
func parse_Identifier():
	var name = eat(TokenType.sym_Identifier).Value

	var \
	node       = PNode.new()
	node.Type  = NodeType.sym_Identifier
	node.Value = name

	return node

#	> AssignmentExpression
# Logical Or Expression
#	:  LogicalAndExpression Logical_Or LogicalOrExpression
#	| LogicalOrExpression
#	;
func parse_LogicalOrExpression():
	var \
	parseFn = FuncRef.new()
	parseFn.set_instance(self)
	parseFn.set_function("pasre_LogicalAndExpression")

	return parse_LogicalExpression(parseFn, TokenType.op_LOr)

#	> LogicaOrExpression
# Logical And Expression
#	: EqualityExpression Logical_And LogicalAndExpression
#	| EqualityExpression
#	;
func pasre_LogicalAndExpression():
	var \
	parseFn = FuncRef.new()
	parseFn.set_instance(self)
	parseFn.set_function("parse_EqualityExpression")

	return parse_LogicalExpression(parseFn, TokenType.op_LAnd)

# Equality Operators: ==, !=
#
#	> LogicalAndExpression
# EqualityExpression
#	: RelationalExpression EqualityOp RelationalExpression
#	| RelationalExpression
#	;
func parse_EqualityExpression():
	var \
	parseFn = FuncRef.new()
	parseFn.set_instance(self)
	parseFn.set_function("parse_RelationalExpression")

	return parse_BinaryExpression(parseFn, TokenType.op_Equality)

# Relational Operators: >, >=, <, <=
#
#	> EqualityExpression
# Relational Expression
#	: AdditiveExpression
#	| AdditiveExpression RelationalOp RelationalExpression
#	;
func parse_RelationalExpression():
	var \
	parseFn = FuncRef.new()
	parseFn.set_instance(self)
	parseFn.set_function("parse_AdditiveExpression")

	return parse_BinaryExpression(parseFn, TokenType.op_Relational)

#	> RelationalExpression
# AdditiveExpression
#	: MultiplicativeExpression
#	| AdditiveExpression AdditiveOp MultiplicativeExpression -> MultiplicativeExpression AdditiveOp ... Literal
#	;
func parse_AdditiveExpression():
	var \
	parseFn = FuncRef.new()
	parseFn.set_instance(self)
	parseFn.set_function("parse_MultiplicativeExpression")

	return parse_BinaryExpression(parseFn, TokenType.op_Additive)

#	> AdditiveExpression
# MultiplicativeExpression
#	: UnaryExpressioon 
#	: MultiplicativeExpression MultiplicativeOp UnaryExpression -> UnaryExpression MultiplicativeOp ... Literal
#	;
func parse_MultiplicativeExpression():
	var \
	parseFn = FuncRef.new()
	parseFn.set_instance(self)
	parseFn.set_function("parse_UnaryExpression")

	return parse_BinaryExpression(parseFn, TokenType.op_Multiplicative)

#	> MultiplicativeExpression
#	> UnaryExpression
# UnaryExpression
#	: ResolvedSymbol
#	| AdditiveOp UnaryExpression
#	| Logical_Not UnaryExpression
#	;
func parse_UnaryExpression():
	var operator
	match NextToken.Type:
		TokenType.op_Additive:
			operator = eat(TokenType.op_Additive).Value
		TokenType.op_LNot:
			operator = eat(TokenType.op_LNot).Value
		
	if operator == null :
		return parse_ResolvedSymbol()
			
	var \
	node       = PNode.new()
	node.Type  = NodeType.expr_Unary
	node.Value = [ operator, parse_UnaryExpression() ]

	return node;

#	> UnaryExpression
#	> PrimaryExpression
# ResolvedSymbol (LeftHandExpression)
#	: MemberExpression
#	;
func parse_ResolvedSymbol():
	return parse_FunctionExpression()

#	> ResolvedSymbol
# FunctionExpression
#	: Super
#	| MemberExpression
#	| CallExpression
#	;
func parse_FunctionExpression():
	if NextToken.Type == TokenType.expr_Super :
		return parse_CallExpression(parse_SuperExpression())

	var member = parse_MemberExpression()

	if NextToken.Type == TokenType.expr_PStart :
		return parse_CallExpression(member)

	return member

#	> FunctionExpression
# Super
#	: super
#	;
func parse_SuperExpression():
	eat(TokenType.expr_Super)

	var \
	node      = PNode.new()
	node.Type = NodeType.expr_Super

	return node

#	> ResolvedSymbol
# MemberExpression
#	: PrimaryExpression
#	| MemberExpression . Identifier
#	| MemberExpression [ Expression ]
#	;
func parse_MemberExpression():
	var expression =  parse_PrimaryExpression()

	while NextToken.Type == TokenType.delim_SMR || NextToken.Type == TokenType.expr_SBStart : 
		if NextToken.Type == TokenType.delim_SMR :
			eat(TokenType.delim_SMR)

			var member = parse_Identifier()

			var \
			node       = PNode.new()
			node.Type  = NodeType.expr_Member
			node.Value = [ false, expression, member ]

			expression = node

		if NextToken.Type == TokenType.expr_SBStart :
			eat(TokenType.expr_SBStart)

			var sbExpression = parse_Expression()

			eat(TokenType.expr_SBEnd)

			var \
			node       = PNode.new()
			node.Type  = NodeType.expr_Member
			node.Value = [ true, expression, sbExpression ]
			
			expression = node

	return expression

#	> FunctionExpression
# CallExpression
#	: Callee Arguments
#	;
#	
# Callee
#	: MemberExpression
#	| CallExpression
#	;
func parse_CallExpression(callee):
	var \
	callExpression       = PNode.new()
	callExpression.Type  = NodeType.expr_Call
	callExpression.Value = \
	[
			callee, 
			parse_Arguments() 
	]

	if NextToken.Type == TokenType.expr_PStart :
		callExpression = parse_CallExpression(callExpression)

	return callExpression

#	> CallExpression
# Arugments
#	: ( OptArgumentList )
#	;
func parse_Arguments():
	eat(TokenType.expr_PStart)

	var argumentList = null

	if NextToken.Type != TokenType.expr_PEnd :
		argumentList = parse_ArgumentList()
	
	eat(TokenType.expr_PEnd)

	return argumentList

#	> Arguments
# ArgumentList
#	: AssignmentExpression
#	| ArgumentList , AssignmentExpression
#	;
func parse_ArgumentList():
	var argumentList = [ parse_AssignmentExpression() ]

	while NextToken.Type == TokenType.delim_Comma :
		eat(TokenType.delim_Comma)

		argumentList.append( parse_AssignmentExpression() )

	return argumentList


#	> MemberExpression
# PrimaryExpression
#	: Literal
#	| ParenthesizedExpression
#	| Identifier
#	| ThisExpression
#	| NewExpression
#	;
func parse_PrimaryExpression():
	if is_Literal():
		return parse_Literal()

	match NextToken.Type:
		TokenType.expr_PStart:
			return parse_ParenthesizedExpression()

		TokenType.sym_Identifier:
			var identifier = parse_Identifier()

			if identifier.Type == NodeType.sym_Identifier :
				return identifier

			var assertStrTmplt = "parse_PrimaryExpression: (Identifier) Unexpected symbol: {value}"
			var assertStr      = assertStrTmplt.format({"value" : identifier.Type})				
			assert(true != true, assertStr)

		TokenType.sym_This :
			return parse_ThisExpression()

		TokenType.expr_New :
				return parse_NewExpression()

	return parse_ResolvedSymbol()

#	> PrimaryExpression
# Literal
#	: NumericLiteral
#	| StringLiteral
#	| BooleanLiteral
#	| NullLiteral
#	;
func parse_Literal():
	match NextToken.Type :
		TokenType.literal_Number:
			return parse_NumericLiteral()
		TokenType.literal_String:
			return parse_StringLiteral()
		TokenType.literal_BTrue:
			return parse_BooleanLiteral(TokenType.literal_BTrue)
		TokenType.literal_BFalse:
			return parse_BooleanLiteral(TokenType.literal_BFalse)
		TokenType.literal_Null:
			return parse_NullLiteral()
			
	assert(false, "parse_Literal: Was not able to detect valid literal type from NextToken")

#	> PrimaryExpression
# ParenthesizedExpression
#	: ( Expression )
#	;
func parse_ParenthesizedExpression():
	eat(TokenType.expr_PStart)

	var expression = parse_Expression()

	eat(TokenType.expr_PEnd)

	return expression

#	> PrimaryExpression
# ThisExpression
#	: this
#	;
func parse_ThisExpression():
	eat(TokenType.sym_This)

	var \
	node      = PNode.new()
	node.Type = NodeType.expr_This

	return node

#	> PrimaryExpression
# NewExpression
#	: new MemberExpression Arugments -> new MyNamespace.MyClass(1, 2);
#	;
func parse_NewExpression():
	eat(TokenType.expr_New)
	
	var memberExp = parse_MemberExpression()
	var args = parse_Arguments()

	var \
	node       = PNode.new()
	node.Type  = NodeType.expr_New
	node.Value = [ memberExp, args ]

	return node;

#	> Literal
# NumericLiteral
#	: Number
#	;
func parse_NumericLiteral():
	var Token = eat(TokenType.literal_Number)
	var \
	node       = PNode.new()
	node.Type  = NodeType.literal_Numeric
	node.Value = int( Token.Value )
	
	return node

#	> Literal
# StringLiteral
#	: String
#	;
func parse_StringLiteral():
	var Token = eat(TokenType.literal_String)
	var \
	node       = PNode.new()
	node.Type  = NodeType.literal_String
	node.Value = Token.Value.substr( 1, Token.Value.length() - 2 )

	return node


#	> Literal
# BooleanLiteral
#	: true
#	| false
#	;
func parse_BooleanLiteral(token):
	eat(token)
	var value
	if (TokenType.literal_BTrue == token) :
		value = true
	elif (TokenType.literal_BFalse == token) :
		value = false

	var \
	node       = PNode.new()
	node.Type  = NodeType.literal_Bool
	node.Value = value

	return node

#	> Literal
# NullLiteral
#	: null
#	;
func parse_NullLiteral():
	eat(TokenType.literal_Null)

	var \
	node       = PNode.new()
	node.Type  = NodeType.literal_Null
	node.Value = null

	return node
	
