class_name Aura extends PanelContainer


@export var minion: Minion
@export var statuses: GridContainer
@export var buffs: HBoxContainer
@export var debuffs: HBoxContainer
@export var overtimes: HBoxContainer

@onready var status_scene = preload("res://scene/8/status.tscn")

var types: Dictionary
var offensives: Array[String]
var defensives: Array[String]


func add_status(bowl_: Bowl) -> void:
	var type = bowl_.status.resource.type
	
	if types.has(type):
		var status = types[type]
		status.resource = status.resource.merge(bowl_.status.resource)
	else:
		var status = status_scene.instantiate()
		types[type] = status
		statuses.add_child(status)
		#status.resource = bowl_.status.resource.duplicate()
		status.aura = self
		status.is_stack = true
		status.resource = bowl_.status.resource.get_stacked_copy(0)
		
		for key in Global.arr.threat:
			if Global.arr[key].has(type):
				var threats = get(key + "s")
				threats.append(type)
				break
	
func change_stack(type_: String, value_: int) -> void:
	var status = types[type_]
	status.resource.stack_value += value_
	
	if status.resource.stack_value > 0:
		status.update_label()
	else:
		for key in Global.arr.threat:
			if Global.arr[key].has(type_):
				var threats = get(key + "s")
				threats.erase(type_)
				break
		
		types.erase(type_)
		statuses.remove_child(status)
		status.queue_free()
