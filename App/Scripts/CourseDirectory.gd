extends Panel


onready var RDP_Viewer  = load("res://RDP/RDP_Viewer.tscn")
onready var RegM_Viewer = load("res://RegM/RegM_Viewer.tscn")
onready var EoI_Viewer  = load("res://EoI/EoI_Viewer.tscn")

onready var RDP_Btn  = get_node("HBox/RDP_Btn")
onready var RegM_Btn = get_node("HBox/RegM_Btn")
onready var EoI_Btn  = get_node("HBox/EoI_Btn")


func rdp_pressed():
	add_child( RDP_Viewer.instance() )
	
func regM_pressed():
	add_child( RegM_Viewer.instance() )
	
func eoi_pressed():
	add_child( EoI_Viewer.instance() )


# Called when the node enters the scene tree for the first time.
func _ready():
	EoI_Btn.connect("pressed", self, "eoi_pressed")
	RDP_Btn.connect("pressed", self, "rdp_pressed")
	RegM_Btn.connect("pressed", self, "regM_pressed")
	
