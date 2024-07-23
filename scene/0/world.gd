@tool
class_name World extends Node


@export var nexus: Nexus
@export var battle: Battle

@export var blabla: int = 0:
	set(blabla_):
		blabla = blabla_
	get:
		return blabla


func _ready() -> void:
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var random = Global.rng.randi_range(0, 1)
	#await get_tree().physics_frame
	pass
	#nexus.generate_prize()
