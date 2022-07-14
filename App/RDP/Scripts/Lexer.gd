extends Object


class_name Lexer


const TokenType : Dictionary = \
{
	# Comments
	cmt_SL = "Comment Single Line",
	cmt_ML = "Comment Multi-Line",
	
	# Formatting
	fmt_S = "Formatting String",
	
	# Delimiters
	delim_Comma = "Comma Delimiter",
	delim_SMR   = "Symbol Member Resolution",

	# Statements
	def_End    = "Statement End",
	def_BStart = "Block Start",
	def_BEnd   = "Block End",
	def_Var    = "Variable Declaration",
	def_Class  = "Class",

	# Iteration
	def_While  = "While",
	def_Do	   = "Do-While",
	def_For    = "For",

	# Procedures
	def_Proc   = "Procedure Declaration",
	def_Return = "Return",

	# Conditional
	def_If   = "If Statement",
	def_Else = "Else Statement",

	# Expressions
	expr_PStart  = "Parenthesis Start",
	expr_PEnd	 = "Parenthesis End",
	expr_SBStart = "Bracket Start",
	expr_SBEnd   = "Bracket End",
	expr_New     = "New Expression",
	expr_Super   = "Super Expression",
	expr_Extends = "Class Extension",

	# Operators

	# Logical
	op_Relational = "Relational",
	op_Equality   = "Equality",
	op_LAnd       = "Logical And",
	op_LOr        = "Logical Or",
	op_LNot       = "Logical Not",

	# Arithmetic
	op_CAssign         = "ComplexAssignment",
	op_Assign          = "Assignment",
	op_Additive        = "AdditiveOperator",
	op_Multiplicative  = "MultiplicativeOperator",

	# Literals
	literal_BTrue  = "True", 
	literal_BFalse = "False",
	literal_Number = "Number",
	literal_String = "String",
	literal_Null   = "Null Value",

	# Symbols
	sym_This        = "This Reference",
	sym_Identifier  = "User Identifier",
}

const Spec : Dictionary = \
{
	# Comments
	TokenType.cmt_SL : "^\\/\\/.*",
	TokenType.cmt_ML : "^\\/\\*[\\s\\S]*?\\*\\/",

	# Formatting
	TokenType.fmt_S : "^\\s+",

	# Delimiters
	TokenType.delim_Comma : "^,",
	TokenType.delim_SMR   : "^\\.",
	
	# Statements
	TokenType.def_End    : "^;",
	TokenType.def_BStart : "^{",
	TokenType.def_BEnd   : "^}",
	TokenType.def_Var    : "^\\blet\\b",
	TokenType.def_Class  : "^\\bclass\\b",

	# Iteration
	TokenType.def_While : "^\\bwhile\\b",
	TokenType.def_Do    : "^\\bdo\\b",
	TokenType.def_For   : "^\\bfor\\b",

	# Procedures
	TokenType.def_Proc   : "^\\bdef\\b",
	TokenType.def_Return : "^\\breturn\\b",

	# Conditional
	TokenType.def_If     : "^\\bif\\b",
	TokenType.def_Else   : "^\\belse\\b",

	# Expressions
	TokenType.expr_PStart  : "^\\(",
	TokenType.expr_PEnd    : "^\\)",
	TokenType.expr_SBStart : "^\\[",
	TokenType.expr_SBEnd   : "^\\]",
	TokenType.expr_New     : "^\\bnew\\b",
	TokenType.expr_Super   : "^\\bsuper\\b",
	TokenType.expr_Extends : "^\\bextends\\b",

	#Operators

	# Logical
	TokenType.op_Relational : "^[>\\<]=?",
	TokenType.op_Equality   : "^[=!]=",
	TokenType.op_LAnd       : "^&&",
	TokenType.op_LOr        : "^\\|\\|",
	TokenType.op_LNot       : "^!",

	# Arithmetic
	TokenType.op_CAssign        : "^[*\\/\\+\\-]=",
	TokenType.op_Assign         : "^=",
	TokenType.op_Additive       : "^[+\\-]",
	TokenType.op_Multiplicative : "^[*\\/]",

	# Literals
	TokenType.literal_BTrue  : "^\\btrue\\b",
	TokenType.literal_BFalse : "^\\bfalse\\b",
	TokenType.literal_Number : "^\\d+",
	TokenType.literal_String : "^\"[^\"]*\"",
	TokenType.literal_Null   : "^\\bnull\\b",

	# Symbols
	TokenType.sym_This       : "^\\bthis\\b",
	TokenType.sym_Identifier : "^\\w+"
}


class Token:
	var Type  : String
	var Value : String


var SourceText : String
var Cursor     : int
var SpecRegex  : Dictionary
var Tokens     : Array
var TokenIndex : int = 0


func compile_regex():
	for type in TokenType.values() :
		var \
		regex = RegEx.new()
		regex.compile( Spec[type] )
		
		SpecRegex[type] = regex
#		SpecRegex[type].compile( Spec[type] )

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
		for type in TokenType.values() :
			var result = SpecRegex[type].search( srcLeft )
			if  result == null || result.get_start() != 0 :
				continue

			# Skip Comments
			if type == TokenType.cmt_SL || type == TokenType.cmt_ML :
				Cursor += result.get_string().length()
				error   = false
				break
				
			# Skip Whitespace
			if type == TokenType.fmt_S :
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
