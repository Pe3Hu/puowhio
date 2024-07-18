class_name Conveyor extends PanelContainer


@export var minion: Minion
@export var equilibrium: EquilibriumResource = EquilibriumResource.new()

@onready var orb_scene = load("res://scene/4/orb.tscn")
@onready var orbs = %Orbs

var front_slot: Slot
var back_slot: Slot


func _ready() -> void:
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
	orb.element = element_
	orb.icon_update()
	equilibrium.change(element_, 1)
	move_front_slot()
	
func move_front_slot() -> void:
	var index = front_slot.get_index() + 1
	
	if index < %Slots.get_child_count():
		front_slot = %Slots.get_child(index)
	else:
		pass
	
func check_orbs_availability(scroll_: Scroll) -> bool:
	if scroll_.resource.equilibrium.inputs.is_empty():
		return true
	
	return equilibrium.is_passes_requirements(scroll_.resource.equilibrium)
