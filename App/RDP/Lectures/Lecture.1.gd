extends Node

# This closesly follows the source provided in the lectures.
# Later on after the lectures are complete or when I deem
# Necessary there will be heavy refactors.
class SyntaxNode:
	var Type  : String
	var Value : int
	
	func Dictionary():
		var result = \
		{ 
			Type  = self.Type,
			Value = self.Value
		}
		return result

class LetterParser:
	var Str : String

	# NumericLiteral
	#	: NUMBER
	#	;
	#
	func NumericLiteral():
		var \
		node = SyntaxNode.new()
		node.Type  = "NumericLiteral"
		node.Value = int(self.Str)
		
		return node

	# Parses the text program description into an AST.
	func Parse(programDescription):
		self.Str = programDescription
		
		return NumericLiteral()


var ProgramDescription = "7"
var LParser = LetterParser.new()

# Note: _ready is being used for Program func of the lectures.
# Main Entry point.
#
# Program
# 	: NumericLiteral
#	;
#
func _ready():
	var ast = LParser.Parse(ProgramDescription)
	
	print(to_json(ast.Dictionary()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



