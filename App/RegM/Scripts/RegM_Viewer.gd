extends Node

var SRegEx = preload("SRegEx.gd").new()

onready var RegEx_TEdit = get_node("RegEx_TEdit")
onready var SRegEx_TEdit = get_node("SRegEx_TEdit")
onready var ToRegEx_Btn = get_node("VBox/ToRegEx_Btn")
onready var Back_Btn    = get_node("VBox/Back_Btn")

func to_RegExBtn_pressed():
	RegEx_TEdit.text = SRegEx.transpile(SRegEx_TEdit.text)
	
#	for line in SRegEx_TEdit.text.split("\n") :
#		RegEx_TEdit.text += SRegEx.transpile( line ) + "\n"

func backBtn_pressed():
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	Back_Btn.connect("pressed", self, "backBtn_pressed")
	ToRegEx_Btn.connect("pressed", self, "to_RegExBtn_pressed")
