class_name Conveyor extends PanelContainer


@export var mage: Mage

@onready var orb_scene = load("res://scene/4/orb.tscn")

var front_slot: Slot
var back_slo: Slot
var presences = {}


func _ready() -> void:
	for element in Global.arr.element:
		presences[element] = []
	
	front_slot = %Slots.get_child(0)
	#var element_ = "fire"
	#add_orb(element_)
	#element_ = "aqua"
	#add_orb(element_)
	#element_ = "wind"
	#add_orb(element_)
	pass
	
func add_orb(element_: String) -> void:
	var orb = orb_scene.instantiate()
	%Orbs.add_child(orb)
	#await get_tree().physics_frame
	front_slot.orb = orb
	orb.resource = Global.tres[element_]
	presences[element_].append(orb)
	move_front_slot()
	
func move_front_slot() -> void:
	var index = front_slot.get_index() + 1
	
	if index < %Slots.get_child_count():
		front_slot = %Slots.get_child(index)
	else:
		pass
	
func check_orbs_availability(scroll_: Scroll) -> bool:
	if scroll_.resource.demands.keys().is_empty():
		return true
	
	for element in scroll_.resource.demands:
		if presences[element].size() < scroll_.resource.demands[element]:
			return false
	
	return true
