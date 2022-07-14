extends Panel


var Lexer  = preload("Lexer.gd").new()
var Parser = preload("Parser.gd").new()


onready var Tokens_TOut = get_node("Tokens_TOut")
onready var AST_TOut    = get_node("AST_TOut")
onready var FDialog     = get_node("Letter_FDialog")
onready var FD_Btn      = get_node("VBox/ParseLetterFile_Btn")
onready var Back_Btn    = get_node("VBox/Back_Btn")


func tokens_out(text):
	Tokens_TOut.insert_text_at_cursor(text)
	
func ast_out(text):
	AST_TOut.insert_text_at_cursor(text)

func parse_file(path):
	var \
	file = File.new()
	file.open(path, File.READ)
	
	var programDescription = file.get_as_text()
	file.close()
	
	Lexer.init(programDescription)
	
	for token in Lexer.Tokens :
		var string =  "[" + token.Type + "] " + token.Value + "\n"
		tokens_out( string )
	
	var ast = Parser.parse(Lexer)
	var json = JSON.print(ast.to_Dictionary(), '\t')

	ast_out(json + "\n")
	ast_out("Finished Parsing!\n")

func fd_btn_pressed():
	FDialog.popup()
	
func fdialog_FSelected(path):
	Tokens_TOut.text = ""
	AST_TOut.text = ""
	parse_file(path)

func backBtn_pressed():
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	FDialog.connect("file_selected", self, "fdialog_FSelected")
	FD_Btn.connect("pressed", self, "fd_btn_pressed")
	Back_Btn.connect("pressed", self, "backBtn_pressed")
