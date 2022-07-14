extends Node

# This closesly follows the source provided in the lectures.
# Later on after the lectures are complete or when I deem
# Necessary there will be heavy refactors.

const TokenType = \
{
	Program    = "Program",
	
	# Comments
	CommentLine      = "CommentLine",
	CommentMultiLine = "CommentMultiLine",
	
	# Formatting
	Whitespace = "Whitespace",

	# Expressions
	ExpressionPStart = "ExpressionParenthesisStart",
	ExpressionPEnd	 = "ExpressionParenthesisEnd",
	expr_SqBStart    = "ExpressionSquareBracketStart",
	expr_SqBEnd      = "ExpressionSquareBracketEnd",

	# Logical
	RelationalOp = "RelationalOperator",
	EqualityOp   = "EqualityOperator",
	Logical_And  = "Logical_And_Op",
	Logical_Or   = "Logical_Or_Op",
	Logical_Not  = "Logical_Not_Op",

	# Arithmetic
	ComplexAssignment = "ComplexAssignment",
	Assignment        = "Assignment",
	AdditiveOp        = "AdditiveOperator",
	MultiplicativeOp  = "MultiplicativeOperator",

	# Conditional
	Conditional_if   = "if Conditional",
	Conditional_else = "else Conditional",
	
	# Statements
	StatementEnd    = "StatementEnd",
	StmtBlockStart  = "BlockStatementStart",
	StmtBlockEnd    = "BlockStatementEnd",
	CommaDelimiter  = "CommaDelimiter",
	MemberDelimiter = "MemberDelimiter",
	
	# Literals 
	Number     = "Number",
	String     = "String",

	# Symbols
	Bool_true   = "Boolean True",
	Bool_false  = "Boolean False",
	VarDeclare  = "Variable Declaration",
	Identifier  = "Identifier",
	NullValue   = "Null Value",
	While       = "While",
	Do		    = "Do",
	For         = "For",
	FuncDeclare = "Function Delcaration",
	Return      = "Return",
	New         = "New",
	Class       = "Class",
	Extends     = "Extends",
	This        = "This",
	Super       = "Super"
}

const TokenSpec = \
{
	# Comments
	TokenType.CommentLine      : "^\\/\\/.*",
	TokenType.CommentMultiLine : "^\\/\\*[\\s\\S]*?\\*\\/",

	# Formatting
	TokenType.Whitespace : "^\\s+",
	
	# Expressions
	TokenType.ExpressionPStart  : "^\\(",
	TokenType.ExpressionPEnd    : "^\\)",
	TokenType.expr_SqBStart     : "^\\[",
	TokenType.expr_SqBEnd       : "^\\]",

	# Logical
	TokenType.RelationalOp : "^[>\\<]=?",
	TokenType.EqualityOp   : "^[=!]=",
	TokenType.Logical_And  : "^&&",
	TokenType.Logical_Or   : "^\\|\\|",
	TokenType.Logical_Not  : "^!",

	# Arithmetic
	TokenType.ComplexAssignment : "^[*\\/\\+\\-]=",
	TokenType.Assignment        : "^=",
	TokenType.AdditiveOp        : "^[+\\-]",
	TokenType.MultiplicativeOp  : "^[*\\/]",

	# Literal
	TokenType.Number : "\\d+",
	TokenType.String : "^\"[^\"]*\"",

	TokenType.Conditional_if   : "^\\bif\\b",
	TokenType.Conditional_else : "^\\belse\\b",

	# Statements
	TokenType.StatementEnd    : "^;",
	TokenType.StmtBlockStart  : "^{",
	TokenType.StmtBlockEnd    : "^}",
	TokenType.CommaDelimiter  : "^,",
	TokenType.MemberDelimiter : "^\\.",

	# Symbols
	TokenType.Bool_true   : "^\\btrue\\b",
	TokenType.Bool_false  : "^\\bfalse\\b",
	TokenType.VarDeclare  : "^\\blet\\b",
	TokenType.NullValue   : "^\\bnull\\b",
	TokenType.While       : "^\\bwhile\\b",
	TokenType.Do          : "^\\bdo\\b",
	TokenType.For         : "^\\bfor\\b",
	TokenType.FuncDeclare : "^\\bdef\\b",
	TokenType.Return      : "^\\breturn\\b",
	TokenType.New         : "^\\bnew\\b",
	TokenType.Class       : "^\\bclass\\b",
	TokenType.Extends     : "^\\bextends\\b",
	TokenType.This        : "^\\bthis\\b",
	TokenType.Super       : "^\\bsuper\\b",
	TokenType.Identifier  : "^\\w+"
}

class Token:
	var Type  : String
	var Value : String
	
	func to_Dictionary():
		var result = \
		{
			Type  = self.Type,
			Value = self.Value
		}
		return result

class Tokenizer:
	var SrcTxt : String
	var Cursor : int;
	
	# Sets up the tokenizer with the program source text.
	func init(programSrcText):
		SrcTxt = programSrcText
		Cursor = 0
	
	# Provides the next token in the source text.
	func next_Token():
		if reached_EndOfTxt() == true :
			return null
			
		var srcLeft = SrcTxt.substr(Cursor)
		var regex   = RegEx.new()
		var token   = Token.new()
		
		for type in TokenSpec :
			regex.compile(TokenSpec[type])
			
			var result = regex.search(srcLeft)
			if  result == null || result.get_start() != 0 :
				continue
				
			# Skip Comments
			if type == TokenType.CommentLine || type == TokenType.CommentMultiLine :
				Cursor += result.get_string().length()
				return next_Token()
				
			# Skip Whitespace
			if type == TokenType.Whitespace :
				var addVal   = result.get_string().length()
				Cursor += addVal
				
				return next_Token()
				
			token.Type   = type
			token.Value  = result.get_string()
			Cursor      += ( result.get_string().length() )
				
			return token
			
		var assertStrTmplt = "next_token: Source text not understood by tokenizer at Cursor pos: {value}"
		var assertStr      = assertStrTmplt.format({"value" : Cursor})
		assert(true != true, assertStr)
		return null
	
	func reached_EndOfTxt():
		return Cursor >= ( SrcTxt.length() )

var GTokenizer = Tokenizer.new()



const SyntaxNodeType = \
{
	NumericLiteral           = "NumericLiteral",
	StringLiteral            = "StringLiteral",
	ExpressionStatement      = "ExpressionStatement",
	BlockStatement           = "BlockStatement",
	EmptyStatement           = "EmptyStatement",
	BinaryExpression         = "BinaryExpression",
	Identifier               = "Identifier",
	AssignmentExpression     = "AssignmentExpression",
	VariableStatement        = "VariableStatement",
	VariableDeclaration      = "VariableDeclaration",
	ConditionalStatement     = "ConditionalStatement",
	BooleanLiteral           = "BooleanLiteral",
	NullLiteral              = "NullLiteral",
	LogicalExpression        = "LogicalExpression",
	UnaryExpression          = "UnaryExpression",
	WhileStatement           = "WhileStatement",
	DoWhileStatement         = "DoWhileStatement",
	ForStatement             = "ForStatement",
	FunctionDeclaration      = "FunctionDeclaration",
	ReturnStatement          = "ReturnStatement",
	MemberExpression         = "MemberExpression",
	CallExpression           = "CallExpression",
	ClassDeclaration         = "ClassDeclaration",
	ClassExtension           = "ClassExtension",
	ThisExpression           = "ThisExpression",
	SuperExpression          = "SuperExpression",
	NewExpression            = "NewExpression"
}

class SyntaxNode:
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

class Parser:
	var TokenizerRef : Tokenizer
	var NextToken    : Token

	# --------------------------------------------------------------------- HELPERS

	# Gets the next token only if the current token is the specified intended token (tokenType)
	func eat(tokenType):
		var currToken = self.NextToken
		
		assert(currToken != null, "eat: NextToken was null")
		
		var assertStrTmplt = "eat: Unexpected token: {value}, expected: {type}"
		var assertStr      = assertStrTmplt.format({"value" : currToken.Value, "type" : tokenType})
		
		assert(currToken.Type == tokenType, assertStr)
		
		NextToken = TokenizerRef.next_Token()
		
		return currToken

	func is_Literal():
		return \
		   NextToken.Type == TokenType.Number     \
		|| NextToken.Type == TokenType.String     \
		|| NextToken.Type == TokenType.Bool_true  \
		|| NextToken.Type == TokenType.Bool_false \
		|| NextToken.Type == TokenType.NullValue
	
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
			nestedNode       = SyntaxNode.new()
			nestedNode.Type  = SyntaxNodeType.BinaryExpression
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
			nestedNode       = SyntaxNode.new()
			nestedNode.Type  = SyntaxNodeType.LogicalExpression
			nestedNode.Value = []
			nestedNode.Value.append(operator)
			nestedNode.Value.append(left)
			nestedNode.Value.append(right)

			left = nestedNode

		return left

	# ------------------------------------------------------------------ END HELPERS

	# Parses the text program description into an AST.
	func parse(TokenizerRef):
		self.TokenizerRef = TokenizerRef
		
		NextToken = TokenizerRef.next_Token()
		
		return parse_Program()

	#	> parse 
	# Program
	#	: StatementList
	# 	: Literal
	#	;
	func parse_Program():
		var \
		node       = SyntaxNode.new()
		node.Type  = TokenType.Program
		node.Value = parse_StatementList(null)
		
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
			TokenType.Conditional_if :
				return parse_If_Statement()
			TokenType.StatementEnd :
				return parse_EmptyStatement()
			TokenType.StmtBlockStart :
				return parse_BlockStatement()
			TokenType.VarDeclare :
				return parse_VariableStatement()
			TokenType.While :
				return parse_IterationStatement()
			TokenType.Do :
				return parse_IterationStatement()
			TokenType.For :
				return parse_IterationStatement()
			TokenType.FuncDeclare:
				return parse_FunctionDeclaration()
			TokenType.Return:
				return parse_ReturnStatement()
			TokenType.Class:
				return parse_ClassDeclaration()

		return parse_ExpressionStatement()
	
	# If Statement
	#	: if ( Expression ) Statement
	#	| if ( Expression ) Statement else Statement
	#	;
	func parse_If_Statement():
		eat(TokenType.Conditional_if)

		eat(TokenType.ExpressionPStart)
		var condition = parse_Expression()
		eat(TokenType.ExpressionPEnd)

		var consequent  = parse_Statement()
		var alternative = null
		
		if NextToken != null && NextToken.Type == TokenType.Conditional_else :
			eat(TokenType.Conditional_else)
			alternative = parse_Statement()

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.ConditionalStatement
		node.Value = [ condition, consequent, alternative ]

		return node

	#	> Statement
	# EmptyStatement
	#	;
	func parse_EmptyStatement():
		eat(TokenType.StatementEnd)
	
		var \
		node      = SyntaxNode.new()
		node.Type = SyntaxNodeType.EmptyStatement
		
		return node

	#	> Statement
	# BlockStatement
	#	: { OptStatementList }
	#	;
	func parse_BlockStatement():
		eat(TokenType.StmtBlockStart)

		var \
		node      = SyntaxNode.new()
		node.Type = SyntaxNodeType.BlockStatement

		if NextToken.Type != TokenType.StmtBlockEnd :
			node.Value = parse_StatementList(TokenType.StmtBlockEnd)
		else :
			node.Value = []

		eat(TokenType.StmtBlockEnd)

		return node

	#	> Statement
	# VariableStatement
	#	: VariableStatementInit StatementEnd
	#	;
	func parse_VariableStatement():
		var varStatement = parse_VariableStatementInit()

		eat(TokenType.StatementEnd)

		return varStatement

	#	> VariableStatement
	# VariableStatementInit
	#	: VarDeclare VariableDeclarationList
	#	;
	func parse_VariableStatementInit():
		eat(TokenType.VarDeclare)
		
		var declarations = parse_VariableDeclarationList()

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.VariableStatement
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
			TokenType.While :
				return parse_WhileStatement()
			TokenType.Do :
				return parse_DoWhileStatement()
			TokenType.For :
				return parse_ForStatement()

	#	> IterationStatement
	# WhileStatement
	#	: while ( Expression ) Statement
	#	;
	func parse_WhileStatement():
		eat(TokenType.While)	

		eat(TokenType.ExpressionPStart)
		var condition = parse_Expression()
		eat(TokenType.ExpressionPEnd)

		var body = parse_Statement()
		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.WhileStatement
		node.Value = [ condition, body ]

		return node

	#	> IterationStatement
	# DoWhileStatement
	#	: do Statement while ( Expression )
	#	;
	func parse_DoWhileStatement():
		eat(TokenType.Do)

		var body = parse_Statement()

		eat(TokenType.While)

		eat(TokenType.ExpressionPStart)
		var condition = parse_Expression()
		eat(TokenType.ExpressionPEnd)

		eat(TokenType.StatementEnd)

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.DoWhileStatement
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
		eat(TokenType.For)

		eat(TokenType.ExpressionPStart)

		var init        = null
		var condition   = null
		var update      = null

		if NextToken.Type != TokenType.StatementEnd :
			init = parse_ForStatementInit()
		eat(TokenType.StatementEnd)

		if NextToken.Type != TokenType.StatementEnd :
			condition = parse_Expression()
		eat(TokenType.StatementEnd)

		if NextToken.Type != TokenType.ExpressionPEnd :
			update = parse_Expression()

		eat(TokenType.ExpressionPEnd)

		var body = parse_Statement()

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.ForStatement
		node.Value = [ init, condition, update, body ]

		return node

	#	> ForStatement
	# ForStatementInit
	#	: VariableStatemetnInit
	#	| Expression
	#	;
	func parse_ForStatementInit():
		if NextToken.Type == TokenType.VarDeclare :
			return parse_VariableStatementInit()

		return parse_Expression()

	#	> Statement
	# FunctionDeclaration
	#	: FuncDeclare ( OptFomralParameterList ) BlockStatement
	#	;
	func parse_FunctionDeclaration():

		eat(TokenType.FuncDeclare)

		var name = parse_Identifier()

		eat(TokenType.ExpressionPStart)

		var params
		if NextToken.Type != TokenType.ExpressionPEnd :
			params = parse_FormalParameterList()
		else :
			params = []

		eat(TokenType.ExpressionPEnd)

		var body = parse_BlockStatement()

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.FunctionDeclaration
		node.Value = [ name, params, body ]

		return node

	#	> FunctionDeclaration
	# FormalParameterList
	#	: Identifier
	#	| FormalParameterList , Identifier
	#	;
	func parse_FormalParameterList():
		var params = [ parse_Identifier() ]

		while NextToken.Type == TokenType.CommaDelimiter :
			eat(TokenType.CommaDelimiter)
			params.append(parse_Identifier())

		return params

	#	> Statement
	# ReturnStatement
	#	: return OptExpression
	#	;
	func parse_ReturnStatement():
		eat(TokenType.Return)

		var argument = null
		if NextToken.Type != TokenType.StatementEnd :
			argument = parse_Expression()
			
		eat(TokenType.StatementEnd)

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.ReturnStatement
		node.Value = argument

		return node

	#	> Statement
	# ClassDeclaration
	#	: class Identifier OptClassExtends BLockStatement
	#	;
	func parse_ClassDeclaration():
		eat(TokenType.Class)

		var identifier = parse_Identifier()
		var superClass = null

		if NextToken.Type == TokenType.Extends :
			superClass = parse_ClassExtension()

		var body = parse_BlockStatement()

		var \
		node = SyntaxNode.new()
		node.Type = SyntaxNodeType.ClassDeclaration
		node.Value = [ identifier, superClass, body ]

		return node

	#	> ClassDeclaration
	# SuperClass
	#	: extends Identifier
	#	;
	func parse_ClassExtension():
		eat(TokenType.Extends)

		return parse_Identifier()

	#	> Statement
	# ExpressionStatement
	#	: Expression
	#	;
	func parse_ExpressionStatement():
		var expression = parse_Expression()
		eat(TokenType.StatementEnd)
		
		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.ExpressionStatement
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

		while NextToken.Type == TokenType.CommaDelimiter :
			eat(TokenType.CommaDelimiter)
			declarations.append(parse_VariableDeclaration())		

		return declarations

	#	> VariableDeclarationList
	# VariableDeclaration
	#	: Identifier OptVariableInitalizer
	#	;
	func parse_VariableDeclaration():
		var identifier = parse_Identifier()
		var initalizer
		if     NextToken.Type != TokenType.StatementEnd \
			&& NextToken.Type != TokenType.CommaDelimiter :
			initalizer = parse_VariableInitializer()
		else :
			initalizer = null

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.VariableDeclaration
		node.Value = [ identifier, initalizer ]

		return node

	#	> VariableDeclaration
	# VariableInitializer
	#	: Assignment AssignmentExpression
	#	;
	func parse_VariableInitializer():
		eat(TokenType.Assignment)

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

		if     NextToken.Type != TokenType.Assignment \
			&& NextToken.Type != TokenType.ComplexAssignment :
			return left

		var assignmentOp;

		if NextToken.Type == TokenType.Assignment :
			assignmentOp = eat(TokenType.Assignment)
		elif NextToken.Type == TokenType.ComplexAssignment :
			assignmentOp = eat(TokenType.ComplexAssignment)

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.AssignmentExpression
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
		var name = eat(TokenType.Identifier).Value

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.Identifier
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

		return parse_LogicalExpression(parseFn, TokenType.Logical_Or)

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

		return parse_LogicalExpression(parseFn, TokenType.Logical_And)

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

		return parse_BinaryExpression(parseFn, TokenType.EqualityOp)

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

		return parse_BinaryExpression(parseFn, TokenType.RelationalOp)

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

		return parse_BinaryExpression(parseFn, TokenType.AdditiveOp)

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

		return parse_BinaryExpression(parseFn, TokenType.MultiplicativeOp)

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
			TokenType.AdditiveOp:
				operator = eat(TokenType.AdditiveOp).Value
			TokenType.Logical_Not:
				operator = eat(TokenType.Logical_Not).Value
			
		if operator == null :
			return parse_ResolvedSymbol()
				
		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.UnaryExpression
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
		if NextToken.Type == TokenType.Super :
			return parse_CallExpression(parse_SuperExpression())

		var member = parse_MemberExpression()

		if NextToken.Type == TokenType.ExpressionPStart :
			return parse_CallExpression(member)

		return member

	#	> FunctionExpression
	# Super
	#	: super
	#	;
	func parse_SuperExpression():
		eat(TokenType.Super)

		var \
		node      = SyntaxNode.new()
		node.Type = SyntaxNodeType.SuperExpression

		return node
	
	#	> ResolvedSymbol
	# MemberExpression
	#	: PrimaryExpression
	#	| MemberExpression . Identifier
	#	| MemberExpression [ Expression ]
	#	;
	func parse_MemberExpression():
		var expression =  parse_PrimaryExpression()

		while NextToken.Type == TokenType.MemberDelimiter || NextToken.Type == TokenType.expr_SqBStart : 
			if NextToken.Type == TokenType.MemberDelimiter :
				eat(TokenType.MemberDelimiter)

				var member = parse_Identifier()

				var \
				node       = SyntaxNode.new()
				node.Type  = SyntaxNodeType.MemberExpression
				node.Value = [ false, expression, member ]

				expression = node

			if NextToken.Type == TokenType.expr_SqBStart :
				eat(TokenType.expr_SqBStart)

				var sbExpression = parse_Expression()

				eat(TokenType.expr_SqBEnd)

				var \
				node       = SyntaxNode.new()
				node.Type  = SyntaxNodeType.MemberExpression
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
		callExpression       = SyntaxNode.new()
		callExpression.Type  = SyntaxNodeType.CallExpression
		callExpression.Value = \
		[
			 callee, 
			 parse_Arguments() 
		]

		if NextToken.Type == TokenType.ExpressionPStart :
			callExpression = parse_CallExpression(callExpression)

		return callExpression

	#	> CallExpression
	# Arugments
	#	: ( OptArgumentList )
	#	;
	func parse_Arguments():
		eat(TokenType.ExpressionPStart)

		var argumentList = null

		if NextToken.Type != TokenType.ExpressionPEnd :
			argumentList = parse_ArgumentList()
		
		eat(TokenType.ExpressionPEnd)

		return argumentList

	#	> Arguments
	# ArgumentList
	#	: AssignmentExpression
	#	| ArgumentList , AssignmentExpression
	#	;
	func parse_ArgumentList():
		var argumentList = [ parse_AssignmentExpression() ]

		while NextToken.Type == TokenType.CommaDelimiter :
			eat(TokenType.CommaDelimiter)

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
			TokenType.ExpressionPStart:
				return parse_ParenthesizedExpression()

			TokenType.Identifier:
				var identifier = parse_Identifier()

				if identifier.Type == SyntaxNodeType.Identifier :
					return identifier

				var assertStrTmplt = "parse_PrimaryExpression: (Identifier) Unexpected symbol: {value}"
				var assertStr      = assertStrTmplt.format({"value" : identifier.Type})				
				assert(true != true, assertStr)

			TokenType.This :
				return parse_ThisExpression()

			TokenType.New :
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
			TokenType.Number:
				return parse_NumericLiteral()
			TokenType.String:
				return parse_StringLiteral()
			TokenType.Bool_true:
				return parse_BooleanLiteral(TokenType.Bool_true)
			TokenType.Bool_false:
				return parse_BooleanLiteral(TokenType.Bool_false)
			TokenType.NullValue:
				return parse_NullLiteral()
				
		assert(false, "parse_Literal: Was not able to detect valid literal type from NextToken")

	#	> PrimaryExpression
	# ParenthesizedExpression
	#	: ( Expression )
	#	;
	func parse_ParenthesizedExpression():
		eat(TokenType.ExpressionPStart)

		var expression = parse_Expression()

		eat(TokenType.ExpressionPEnd)

		return expression

	#	> PrimaryExpression
	# ThisExpression
	#	: this
	#	;
	func parse_ThisExpression():
		eat(TokenType.This)

		var \
		node      = SyntaxNode.new()
		node.Type = SyntaxNodeType.ThisExpression

		return node

	#	> PrimaryExpression
	# NewExpression
	#	: new MemberExpression Arugments -> new MyNamespace.MyClass(1, 2);
	#	;
	func parse_NewExpression():
		eat(TokenType.New)
		
		var memberExp = parse_MemberExpression()
		var args = parse_Arguments()

		var \
		node = SyntaxNode.new()
		node.Type = SyntaxNodeType.NewExpression
		node.Value = [ memberExp, args ]

		return node;

	#	> Literal
	# NumericLiteral
	#	: Number
	#	;
	func parse_NumericLiteral():
		var Token = eat(TokenType.Number)
		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.NumericLiteral
		node.Value = int( Token.Value )
		
		return node
	
	#	> Literal
	# StringLiteral
	#	: String
	#	;
	func parse_StringLiteral():
		var Token = eat(TokenType.String)
		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.StringLiteral
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
		if (TokenType.Bool_true == token) :
			value = true
		elif (TokenType.Bool_false == token) :
			value = false

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.BooleanLiteral
		node.Value = value

		return node

	#	> Literal
	# NullLiteral
	#	: null
	#	;
	func parse_NullLiteral():
		eat(TokenType.NullValue)

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.NullLiteral
		node.Value = null

		return node

var GParser = Parser.new()



onready var TextOut = GScene.get_node("TextOutput")
onready var FDialog = GScene.get_node("Letter_FDialog")
onready var FD_Btn  = GScene.get_node("ParseLetterFile_Btn")

func tout(text):
	TextOut.insert_text_at_cursor(text)

func parse_file(path):
	var \
	file = File.new()
	file.open(path, File.READ)
	
	var programDescription = file.get_as_text()
	file.close()
	
	GTokenizer.init(programDescription)
	var ast = GParser.parse(GTokenizer)
	
	var json = JSON.print(ast.to_Dictionary(), '\t')
	
	tout(json + "\n")
	tout("Finished Parsing!\n")

func fd_btn_pressed():
	FDialog.popup()
	
func fdialog_FSelected(path):
	parse_file(path)

# Main Entry point.
func _ready():
	FDialog.connect("file_selected", self, "fdialog_FSelected")
	FD_Btn.connect("pressed", self, "fd_btn_pressed")
	
	

