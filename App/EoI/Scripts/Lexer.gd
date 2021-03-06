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

class_name Lexer

var SRegEx = preload("res://RegM/Scripts/SRegex.gd").new()


const TType : Dictionary = \
{
	fmt_S  = "Formatting",
	cmt_SL = "Comment Single-Line",
	cmt_ML = "Comment Multi-Line",
	
	def_Start  = "Expression Start",
	def_End    = "Expression End",
	def_Block  = "Expression Block Start",
	def_Cond   = "Expression Conditional",
	def_Switch = "Expresssion Switch",
	def_While  = "Expression While",
	def_For    = "Expression For",
	def_Var    = "Variable Declaration",
	def_Func   = "Function Declaration",
	def_Lambda = "Lambda Declaration",
	
	literal_Number = "Literal: Number",
	literal_String = "Literal: String",
	
	op_Assgin     = "Assignment",
	op_Numeric    = "Numeric Operation",
	op_Relational = "Relational Operation",
	op_Equality   = "Equality Operation",
	
	fn_Print = "Print",
	
	identifier = "Identifier"
}

const Spec : Dictionary = \
{
	TType.cmt_SL : "start // inline.repeat(0-)",
	TType.cmt_ML : "start /* set(whitespace !whitespace).repeat(0-).lazy */",
	
	TType.fmt_S : "start whitespace.repeat(1-).lazy",

	TType.def_Start  : "start \\(",
	TType.def_End    : "start \\)",
	TType.def_Block  : "start \"begin\"",
	TType.def_Cond   : "start \"if\"",
	TType.def_Switch : "start \"switch\"",
	TType.def_While  : "start \"while\"",
	TType.def_For    : "start \"for\"",
	TType.def_Var    : "start \"var\"",
	TType.def_Func   : "start \"def\"",
	TType.def_Lambda : "start \"lambda\"",
	
	TType.literal_Number : \
	"""start 
		set(+ \\-).repeat(0-1)	
		( set(0-9).repeat(1-) \\. ).repeat(0-1) 
		set(0-9).repeat(1-) 
	""",
	TType.literal_String : "start \\\" !set( \\\" ).repeat(0-) \\\" ",
	
	TType.op_Assgin     : "start \"set\"",
	TType.op_Numeric    : "start set(+ \\- * /) set(+ \\-).repeat(0-1)",
	TType.op_Relational : "start set(> <) =.repeat(0-1)",
	TType.op_Equality   : "start \\!.repeat(0-1) =",
	
	TType.fn_Print : "start \"print\"",
	
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


func _init(programSrcText, errorOut) :
	ErrorOut = errorOut

	SourceText = programSrcText
	Cursor     = 0
	TokenIndex = 0

	if SpecRegex.size() == 0 :
		compile_regex()

	tokenize()
