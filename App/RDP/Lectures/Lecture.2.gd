extends Node

# This closesly follows the source provided in the lectures.
# Later on after the lectures are complete or when I deem
# Necessary there will be heavy refactors.

enum TokenTypes \
{
	Token_Number,
	Token_String
}

const StrTokenTypes = \
{
	Token_Number = "Number",
	Token_String = "String"
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
			
		var token = self.SrcTxt.substr(Cursor)
		
		# Numbers
		if token[self.Cursor].is_valid_integer() :
			var \
			numberTok       = Token.new()
			numberTok.Type  = "Number"
			numberTok.Value = ""
	
			while token.length() > self.Cursor && token[self.Cursor].is_valid_integer() :
				numberTok.Value += token[self.Cursor]
				self.Cursor     += 1
				
			return numberTok

		# String:
		if token[self.Cursor] == '"' :
			var \
			stringTok       = Token.new()
			stringTok.Type  = "String"
			stringTok.Value = "\""	
			
			self.Cursor += 1
			
			while token.length() > self.Cursor :
				stringTok.Value += token[self.Cursor]
				self.Cursor     += 1
			
			return stringTok
		
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
			"Number":
				return parse_NumericLiteral()
			"String":
				return parse_StringLiteral()
				
		assert(false, "parse_Literal: Was not able to detect valid literal type from NextToken")
		
	# NumericLiteral
	#	: Number
	#	;
	#
	func parse_NumericLiteral():
		var Token = self.eat("Number")
		var \
		node       = SyntaxNode.new()
		node.Type  = "NumericLiteral"
		node.Value = int( Token.Value )
		
		return node
	
	# StringLiteral
	#	: String
	#	;
	#
	func parse_StringLiteral():
		var Token = self.eat("String")
		var \
		node = SyntaxNode.new()
		node.Type  = "StringLiteral"
		node.Value = Token.Value.substr( 1, Token.Value.length() - 2 )

		return node
	
	# Program
	# 	: Literal
	#	;
	#
	func parse_Program():
		var \
		node      = ProgramNode.new()
		node.Type = "Program"
		node.Body = parse_Literal()
		
		return node

	# Parses the text program description into an AST.
	func parse(TokenizerRef):
		self.TokenizerRef = TokenizerRef
		
		NextToken = TokenizerRef.next_Token()
		
		return parse_Program()

var GParser = Parser.new()



# Main Entry point.
func _ready():
	# Numerical test
	var ProgramDescription = "47"
	GTokenizer.init(ProgramDescription)
	
	var ast = GParser.parse(GTokenizer)
	print(JSON.print(ast.toDict(), "\t"))
	
	# String Test
	ProgramDescription = "\"hello\""
	GTokenizer.init(ProgramDescription)
	
	ast = GParser.parse(GTokenizer)
	print(JSON.print(ast.toDict(), "\t"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



