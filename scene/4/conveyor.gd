class_name Conveyor extends PanelContainer


@export var mage: Mage

var front: int = 0
var back: int = 11


func _ready() -> void:
	var element_ = "fire"
	add_orb(element_)
	
func add_orb(element_: String) -> void:
	var index = front
	var orb = %Orbs.get_child(index)
	
	orb.resource = Global.tres[element_]
	orb.tRect.visible = true
