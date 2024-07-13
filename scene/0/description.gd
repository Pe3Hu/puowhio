class_name Description extends MenuBar


@export var item: Item

@onready var doublet_scene = load("res://scene/0/doublet.tscn")


func init_doublets() -> void:
	for base in item.resource.bases:
		var doublet = doublet_scene.instantiate()
		doublet.set_from_base(base)
		%Aspects.add_child(doublet)
	
	for base in item.resource.affixs:
		var doublet = doublet_scene.instantiate()
		doublet.set_from_affix(base)
		%Parameters.add_child(doublet)
