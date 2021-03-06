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

	ExpressionPStart  = "Expresssion Parenthesis Start",
	ExpressionPEnd	  = "Expression Parenthesis End",

	# Arithmetic
	AdditiveOp       = "AdditiveOperator",
	MultiplicativeOp = "MultiplicativeOperator",
	
	# Statements
	StatementEnd   = "StatementEnd",
	StmtBlockStart = "BlockStatementStart",
	StmtBlockEnd   = "BlockStatementEnd",
	
	# Literals
	Number     = "Number",
	String     = "String"
}

const TokenSpec = \
{
	# Comments
	TokenType.CommentLine      : "^\/\/.*",
	TokenType.CommentMultiLine : "^\/\\*[\\s\\S]*?\\*\/",

	# Formatting
	TokenType.Whitespace : "^\\s+",
	
	# Expressions
	TokenType.ExpressionPStart : "^\\(",
	TokenType.ExpressionPEnd   : "^\\)",

	# Arithmetic
	TokenType.AdditiveOp       : "^[+\\-]",
	TokenType.MultiplicativeOp : "^[*\\/]",

	# Literal
	TokenType.Number : "\\d+",
	TokenType.String : "^\"[^\"]*\"",

	# Statements
	TokenType.StatementEnd   : "^;",
	TokenType.StmtBlockStart : "^{",
	TokenType.StmtBlockEnd   : "^}"
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
	# MultiplicativeExpression = "MultiplicativeExpression"
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
	
		# Literal
	#	: NumericLiteral
	#	: StringLiteral
	#	;
	func parse_Literal():
		match NextToken.Type :
			TokenType.Number:
				return parse_NumericLiteral()
			TokenType.String:
				return parse_StringLiteral()
				
		assert(false, "parse_Literal: Was not able to detect valid literal type from NextToken")
	
	# ParenthesizedExpression
	#	: ( Expression )
	#	;
	func parse_ParenthesizedExpression():
		eat(TokenType.ExpressionPStart)

		var expression = parse_Expression()

		eat(TokenType.ExpressionPEnd)

		return expression

	# PrimaryExpression
	#	: Literal
	#	| ParenthesizedExpression
	#	;
	func parse_PrimaryExpression():
		match NextToken.Type:
			TokenType.ExpressionPStart:
				return parse_ParenthesizedExpression()

		return parse_Literal()

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
	
	# Expression
	#	: Literal
	#	: AdditiveExpression
	#	;
	func parse_Expression():
		return parse_AdditiveExpression()
		
	# EmptyStatement
	#	;
	func parse_EmptyStatement():
		eat(TokenType.StatementEnd)
	
		var \
		node      = SyntaxNode.new()
		node.Type = SyntaxNodeType.EmptyStatement
		
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
	#	: BlockStatement
	#	: EmptyStatement
	#	;
	func parse_Statement():
		match NextToken.Type :
			TokenType.StatementEnd :
				return parse_EmptyStatement()
			TokenType.StmtBlockStart :
				return parse_BlockStatement()

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
	
	var json = JSON.print(ast.to_SExpression(), '\t')
	
	tout(json + "\n")
	tout("Passed!\n")


# Main Entry point.
func _ready():
	for Key in Tests :
		test(Tests[Key])
