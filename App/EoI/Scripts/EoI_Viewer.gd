extends Node


# Eva -------------------------------------------------------
const SLexer = preload("Lexer.gd")
var   Lexer  : SLexer

const SParser = preload("Parser.gd")
var   Parser  : SParser

const SEva = preload("Eva.gd")
var   Eva : SEva


# UX --------------------------------------------------------
onready var Editor        = get_node("Editor_TEdit")
onready var Output        = get_node("Output_TEdit")
onready var Debug         = get_node("Debug_TEdit")
onready var Eva_Btn       = get_node("VBox/Eva_Interpret_Btn")
onready var Eva_Reset_Btn = get_node("VBox/Eva_ResetEnv_Btn")
onready var Clear_Btn     = get_node("VBox/ClearOutput_Btn")
onready var Back_Btn      = get_node("VBox/Back_Btn")


func evaBtn_pressed():
	Lexer  = SLexer.new(Editor.text, Output)
	Parser = SParser.new(Lexer, Output)

	var ast    = Parser.parse()
	var result = Eva.eval(ast)
	
	if result != null:
		Output.text += "\nResult: " + result
	
	Debug.text = JSON.print( Eva.get_EnvSnapshot(), "\t" )
	
func evaResetBtn_pressed():
	Eva        = SEva.new(null, Output)
	Debug.text = JSON.print( Eva.get_EnvSnapshot(), "\t" )
	
func clearBtn_pressed():
	Output.text = ""
 
func backBtn_pressed():
	queue_free()


func _ready():
	Eva        = SEva.new(null, Output)
	Debug.text = JSON.print( Eva.get_EnvSnapshot(), "\t" )
	
	Eva_Btn.connect("pressed", self, "evaBtn_pressed")
	Eva_Reset_Btn.connect("pressed", self, "evaResetBtn_pressed")
	Clear_Btn.connect("pressed", self, "clearBtn_pressed")
	Back_Btn.connect("pressed", self, "backBtn_pressed")
