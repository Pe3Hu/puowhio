@tool
class_name World extends Node


@export var nexus: Nexus
@export var battle: Battle

@export var mage: int = 0:
	set(mage_):
		mage = mage_
	get:
		return mage


func _ready() -> void:
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var random = Global.rng.randi_range(0, 1)
	pass



