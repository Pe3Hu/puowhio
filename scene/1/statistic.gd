@tool
class_name Statistic extends PanelContainer


@export var mage: Mage

@export var refreshed: bool = false:
	set(refreshed_):
		refreshed = refreshed_
		
		if is_node_ready():
			for doublet in %Parameters.get_children():
				doublet.resource = doublet.resource
			for doublet in %Aspects.get_children():
				doublet.resource = doublet.resource
	get:
		return refreshed

@export var cores: Array[CoreResource]

@onready var strength = %Strength
@onready var dexterity = %Dexterity
@onready var intellect = %Intellect
@onready var will = %Will


func _ready() -> void:
	refreshed = !refreshed
	
	roll_cores()
	
func roll_cores() -> void:
	var rolls = [3, 2, 1, 0]
	var aspects = []
	aspects.append_array(Global.arr.aspect)
	aspects.shuffle()
	
	while !rolls.is_empty():
		var roll = rolls.pop_back()
		var aspect = aspects.pop_back()
		recalc_core(aspect, roll)
	
func recalc_core(type_: String, value_: int) -> void:
	var index = Global.arr.aspect.find(type_)
	var core = cores[index]
	core.current += value_
	var doublet = get(type_)
	doublet.value = core.current
