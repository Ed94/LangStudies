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
	ExpressionPStart  = "ExpresssionParenthesisStart",
	ExpressionPEnd	  = "ExpressionParenthesisEnd",

	# Logical
	RelationalOp = "RelationalOperator",
	EqualityOp   = "EqualityOperator",
	Logical_And  = "Logical_And_Op",
	Logical_Or   = "Logical_Or_Op",

	# Arithmetic
	ComplexAssignment = "ComplexAssignment",
	Assignment        = "Assignment",
	AdditiveOp        = "AdditiveOperator",
	MultiplicativeOp  = "MultiplicativeOperator",

	# Conditional
	Conditional_if   = "if Conditional",
	Conditional_else = "else Conditional",
	
	# Statements
	StatementEnd   = "StatementEnd",
	StmtBlockStart = "BlockStatementStart",
	StmtBlockEnd   = "BlockStatementEnd",
	CommaDelimiter = "CommaDelimiter",
	
	# Literals 
	Number     = "Number",
	String     = "String",

	# Symbols
	Bool_true  = "Boolean True",
	Bool_false = "Boolean False",
	VarDeclare = "Variable Declaration",
	Identifier = "Identifier",
	NullValue  = "Null Value"
}

const TokenSpec = \
{
	# Comments
	TokenType.CommentLine      : "^\\/\\/.*",
	TokenType.CommentMultiLine : "^\\/\\*[\\s\\S]*?\\*\\/",

	# Formatting
	TokenType.Whitespace : "^\\s+",
	
	# Expressions
	TokenType.ExpressionPStart : "^\\(",
	TokenType.ExpressionPEnd   : "^\\)",

	# Logical
	TokenType.RelationalOp : "^[>\\<]=?",
	TokenType.EqualityOp   : "^[=!]=",
	TokenType.Logical_And  : "^&&",
	TokenType.Logical_Or   : "^\\|\\|",

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
	TokenType.StatementEnd   : "^;",
	TokenType.StmtBlockStart : "^{",
	TokenType.StmtBlockEnd   : "^}",
	TokenType.CommaDelimiter : "^,",

	# Symbols
	TokenType.Bool_true  : "^\\btrue\\b",
	TokenType.Bool_false : "^\\bfalse\\b",
	TokenType.VarDeclare : "^\\blet\\b",
	TokenType.Identifier : "^\\w+",
	TokenType.NullValue  : "^\\bnull\\b"
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



const AST_Format = \
{
	Dictionary  = "Dictionary",
	SExpression = "S-Expression"
}

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
	LogicalExpression        = "LogicalExpression"
}

class SyntaxNode:
	var Type  : String
	var Value # Not specifing a type implicity declares a Variant type.

	func to_SExpression():
		var expression = [ Type ]

		if typeof(Value) == TYPE_ARRAY :
			var array = []
			for entry in self.Value :
				if typeof(entry) == TYPE_OBJECT :
					array.append( entry.to_SExpression() )
				else :
					array.append( entry )
			
			expression.append(array)
			return expression
			
		if typeof(Value) == TYPE_OBJECT :
			var result = [ Type, Value.to_SExpression() ]
			return result
			
		expression.append(Value)
		return expression
	
	func to_Dictionary():
		if typeof(Value) == TYPE_ARRAY :
			var array = []
			for entry in self.Value :
				if typeof(entry) == TYPE_OBJECT :
					array.append( entry.to_Dictionary() )
				else :
					array.append( entry )
					
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
	
	func is_Literal():
		return \
		   NextToken.Type == TokenType.Number \
		|| NextToken.Type == TokenType.String \
		|| NextToken.Type == TokenType.Bool_true \
		|| NextToken.Type == TokenType.Bool_false \
		|| NextToken.Type == TokenType.NullValue
	
	func eat(tokenType):
		var currToken = self.NextToken
		
		assert(currToken != null, "eat: NextToken was null")
		
		var assertStrTmplt = "eat: Unexpected token: {value}, expected: {type}"
		var assertStr      = assertStrTmplt.format({"value" : currToken.Value, "type" : tokenType})
		
		assert(currToken.Type == tokenType, assertStr)
		
		NextToken = TokenizerRef.next_Token()
		
		return currToken

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

	# NullLiteral
	#	: null
	#	;
	func parse_NullLiteral():
		eat(TokenType.NullLiteral)

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.NullLiteral
		node.Value = null

		return node
			
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

	# ParenthesizedExpression
	#	: ( Expression )
	#	;
	func parse_ParenthesizedExpression():
		eat(TokenType.ExpressionPStart)

		var expression = parse_Expression()

		eat(TokenType.ExpressionPEnd)

		return expression

	# Relational Operators: >, >=, <, <=
	#
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

	# Equality Operators: ==, !=
	#
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

	# MultiplicativeExpression
	#	: PrimaryExpression
	#	: MultiplicativeExpression MultiplicativeOp PrimaryExpression -> PrimaryExpression MultiplicativeOp ... Literal
	#	;
	func parse_MultiplicativeExpression():
		var \
		parseFn = FuncRef.new()
		parseFn.set_instance(self)
		parseFn.set_function("parse_PrimaryExpression")

		return parse_BinaryExpression(parseFn, TokenType.MultiplicativeOp)

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

	# ResolvedSymbol
	#	: Identiifer
	#	;
	func parse_ResolvedSymbol():
		var resolvedSymbol = parse_Identifier()

		if resolvedSymbol.Type == SyntaxNodeType.Identifier :
			return resolvedSymbol

		var assertStrTmplt = "parse_ResolvedSymbol: Unexpected symbol: {value}"
		var assertStr      = assertStrTmplt.format({"value" : resolvedSymbol.Type})

		assert(true != true, assertStr)
		
	# PrimaryExpression
	#	: Literal
	#	| ParenthesizedExpression
	#	| ResolvedSymbol
	#	;
	func parse_PrimaryExpression():
		if is_Literal():
			return parse_Literal()

		match NextToken.Type:
			TokenType.ExpressionPStart:
				return parse_ParenthesizedExpression()

		return parse_ResolvedSymbol()
	
	# AssignmentExpression
	#	: RelationalExpression
	#	| ResolvedSymbol AssignmentOperator AssignmetnExpression 
	#	;
	func parse_AssignmentExpression():
		var left = parse_LogicalOrExpression()

		if NextToken.Type != TokenType.Assignment && NextToken.Type != TokenType.ComplexAssignment :
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

	# Expression
	#	: AssignmentExpression
	#	;
	func parse_Expression():
		return parse_AssignmentExpression()
		
	# EmptyStatement
	#	;
	func parse_EmptyStatement():
		eat(TokenType.StatementEnd)
	
		var \
		node      = SyntaxNode.new()
		node.Type = SyntaxNodeType.EmptyStatement
		
		return node

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

	# VariableInitializer
	#	: Assignment AssignmentExpression
	#	;
	func parse_VariableInitializer():
		eat(TokenType.Assignment)

		return parse_AssignmentExpression()

	# VariableDeclaration
	#	: Identifier OptVariableInitalizer
	#	;
	func parse_VariableDeclaration():
		var identifier = parse_Identifier()
		var initalizer
		if NextToken.Type != TokenType.StatementEnd && NextToken.Type != TokenType.CommaDelimiter :
			initalizer = parse_VariableInitializer()
		else :
			initalizer = null

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.VariableDeclaration
		node.Value = [ identifier, initalizer ]

		return node

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

	# VariableStatement
	#	: VarDeclare VariableDeclarationList StatementEnd
	#	;
	func parse_VariableStatement():
		eat(TokenType.VarDeclare)

		var declarations = parse_VariableDeclarationList()

		eat(TokenType.StatementEnd)

		var \
		node       = SyntaxNode.new()
		node.Type  = SyntaxNodeType.VariableStatement
		node.Value = declarations

		return node

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
		
	# Statement
	# 	: ExpressionStatement
	#	| BlockStatement
	#	| EmptyStatement
	#	| VariableStatement
	#   | If_Statement
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

		return parse_ExpressionStatement()
	
	# StatementList
	#	: Statement
	#	| StatementList Statement -> Statement ...
	#	;
	func parse_StatementList(endToken):
		var statementList = [ parse_Statement() ]
		
		while NextToken != null && NextToken.Type != endToken :
			statementList.append( parse_Statement() )
			
		return statementList
	
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

	# Parses the text program description into an AST.
	func parse(TokenizerRef):
		self.TokenizerRef = TokenizerRef
		
		NextToken = TokenizerRef.next_Token()
		
		return parse_Program()

var GParser = Parser.new()



onready var TextOut = GScene.get_node("TextOutput")

func tout(text):
	TextOut.insert_text_at_cursor(text)

const Tests = \
{
	MultiStatement = \
	{
		Name = "Multi-Statement",
		File = "1.Multi-Statement.uf"
	},
	BlockStatement = \
	{
		Name = "Block Statement",
		File = "2.BlockStatement.uf"
	},
	BinaryExpression = \
	{
		Name = "Binary Expression",
		File = "3.BinaryExpression.uf"
	},
	Assignment = \
	{
		Name = "Assignment",
		File = "4.Assignment.uf"
	},
	VaraibleDeclaration = \
	{
		Name = "Variable Declaration",
		File = "5.VariableDeclaration.uf"
	},
	Conditionals = \
	{
		Name = "Conditionals",
		File = "6.Conditionals.uf"
	},
	Relations = \
	{
		Name = "Relations",
		File = "7.Relations.uf"
	},
	Equality = \
	{
		Name = "Equality",
		File = "8.Equality.uf"
	},
	Logical = \
	{
		Name = "Logical",
		File = "9.Logical.uf"
	}
}

func test(entry):
	var introMessage          = "Testing: {Name}\n"
	var introMessageFormatted = introMessage.format({"Name" : entry.Name})
	tout(introMessageFormatted)
	
	var path
	if  Engine.editor_hint :
		path          = "res://../Tests/{TestName}"	
	else :
		path          = "res://../Builds/Tests/{TestName}"
	var pathFormatted = path.format({"TestName" : entry.File})
	
	var \
	file = File.new()
	file.open(pathFormatted, File.READ)
	
	var programDescription = file.get_as_text()
	file.close()
	
	GTokenizer.init(programDescription)
	var ast = GParser.parse(GTokenizer)
	
	var json = JSON.print(ast.to_Dictionary(), '\t')
	
	tout(json + "\n")
	tout("Passed!\n")


# Main Entry point.
func _ready():
	for Key in Tests :
		test(Tests[Key])
