extends Node

const JsonBeautifier = preload("res://ThirdParty/json_beautifier.gd")

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
	
	# Literals
	Number     = "Number",
	String     = "String"
}

const TokenSpec = \
{
	TokenType.CommentLine      : "^\/\/.*",
	TokenType.CommentMultiLine : "^\/\\*[\\s\\S]*?\\*\/",
	TokenType.Whitespace       : "^\\s+",
	TokenType.Number           : "\\d+",
	TokenType.String           : "^\"[^\"]*\""
}

class Token:
	var Type  : String
	var Value : String
	
	func toDict():
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
		if self.reached_EndOfTxt() == true :
			return null
			
		var srcLeft = self.SrcTxt.substr(Cursor)
		var regex   = RegEx.new()
		var token   = Token.new()
		
		for type in TokenSpec :
			regex.compile(TokenSpec[type])
			
			var result = regex.search(srcLeft)
			if  result == null :
				continue
				
			# Skip Comments
			if type == TokenType.CommentLine || type == TokenType.CommentMultiLine :
				self.Cursor += result.get_string().length()
				return next_Token()
				
			# Skip Whitespace
			if type == TokenType.Whitespace :
				var addVal = result.get_string().length()
				self.Cursor += addVal
				
				return next_Token()
				
			token.Type   = type
			token.Value  = result.get_string()
			self.Cursor += ( result.get_string().length() -1 )
				
			return token
			
		var assertStrTmplt = "next_token: Source text not understood by tokenizer at Cursor pos: {value}"
		var assertStr      = assertStrTmplt.format({"value" : self.Cursor})
		assert(true != true, assertStr)
		return null
	
	func reached_EndOfTxt():
		return self.Cursor >= ( self.SrcTxt.length() - 1 )
		
var GTokenizer = Tokenizer.new()


class SyntaxNode:
	var Type  : String
	var Value # Not specifing a type implicity declares a Variant type.
	
	func toDict():
		var result = \
		{ 
			Type  = self.Type,
			Value = self.Value
		}
		return result

class ProgramNode:
	var Type : String
	var Body : Object
	
	func toDict():
		var result = \
		{
			Type = self.Type,
			Body = self.Body.toDict()
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
		
		self.NextToken = self.TokenizerRef.next_Token()
		
		return currToken
	
	# Literal
	#	: NumericLiteral
	#	: StringLiteral
	#	;
	func parse_Literal():
		match self.NextToken.Type :
			TokenType.Number:
				return parse_NumericLiteral()
			TokenType.String:
				return parse_StringLiteral()
				
		assert(false, "parse_Literal: Was not able to detect valid literal type from NextToken")
		
	# NumericLiteral
	#	: Number
	#	;
	#
	func parse_NumericLiteral():
		var Token = self.eat(TokenType.Number)
		var \
		node       = SyntaxNode.new()
		node.Type  = TokenType.Number
		node.Value = int( Token.Value )
		
		return node
	
	# StringLiteral
	#	: String
	#	;
	#
	func parse_StringLiteral():
		var Token = self.eat(TokenType.String)
		var \
		node = SyntaxNode.new()
		node.Type  = TokenType.String
		node.Value = Token.Value.substr( 1, Token.Value.length() - 2 )

		return node
	
	# Program
	# 	: Literal
	#	;
	#
	func parse_Program():
		var \
		node      = ProgramNode.new()
		node.Type = TokenType.Program
		node.Body = parse_Literal()
		
		return node

	# Parses the text program description into an AST.
	func parse(TokenizerRef):
		self.TokenizerRef = TokenizerRef
		
		NextToken = TokenizerRef.next_Token()
		
		return parse_Program()

var GParser = Parser.new()


var ProgramDescription : String

func test():
	GTokenizer.init(ProgramDescription)
	
	var ast = GParser.parse(GTokenizer)
	
	print(JsonBeautifier.beautify_json(to_json(ast.toDict())))
	

# Main Entry point.
func _ready():
	# Numerical test
	ProgramDescription = "47"
	test()
	
	# String Test
	ProgramDescription = "\"hello\""
	test()

	# Whitespace test
	ProgramDescription = "     \"we got past whitespace\"       "
	test()
	
	# Comment Single Test
	ProgramDescription = \
	"""
	// Testing a comment    
	\"hello sir\"       
	"""
	test()
	
	# Comment Multi-Line Test
	ProgramDescription = \
	"""
	/**
	*
	* Testing a comment    
	*/
	\"may I have some grapes\"       
	"""
	test()
	
	# Multi-statement test
	ProgramDescription = \
	"""
	// Testing a comment    
	\"hello sir\";
	
	/**
	*
	* Testing a comment    
	*/
	\"may I have some grapes\";    
	"""
	test()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



