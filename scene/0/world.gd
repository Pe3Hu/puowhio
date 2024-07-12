extends Node


@export var resource: int = 0:
	set(resource_):
		resource = resource_
	get:
		return resource


func _ready() -> void:
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.rng.randomize()
	#var random = Global.rng.randi_range(0, 1)
	pass





#@export var core_dexterity: int = 0:
	#set(core_dexterity_):
		#core_dexterity = core_dexterity_
		#recalc_core("will")
	#get:
		#return core_dexterity
#
#@export var core_intellect: int = 0:
	#set(core_intellect_):
		#core_intellect = core_intellect_
		#recalc_core("will")
	#get:
		#return core_intellect
#
#@export var core_strength: int = 0:
	#set(core_strength_):
		#core_strength = core_strength_
		#recalc_core("will")
	#get:
		#return core_strength
#
#@export var core_will: int = 0:
	#set(core_will_):
		#core_will = core_will_
		#recalc_core("will")
	#get:
		#return core_will
