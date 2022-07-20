extends Node

var eva = preload("Eva.gd").new()














# UX --------------------------------------------------------
onready var Editor   = get_node("Editor_TEdit")
onready var Output   = get_node("Output_TEdit")
onready var Eva_Btn  = get_node("VBox/Eva_Interpret_Btn")
onready var Back_Btn = get_node("VBox/Back_Btn")


func evaBtn_pressed():
	eva.init(Editor.text)
	
	var ast = eva.parse()
	
	Output.text = eva.eval(ast)

func backBtn_pressed():
	queue_free()


func _ready():
	Eva_Btn.connect("pressed", self, "evaBtn_pressed")
	Back_Btn.connect("pressed", self, "backBtn_pressed")
