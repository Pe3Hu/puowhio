extends PanelContainer


@export var awards: HBoxContainer
#@export var resources: Array[AwardResource]

@onready var award_scene = preload("res://scene/10/award.tscn")


func add_award(resource_: AwardResource) -> void:
	#resources.append(resource_)
	var award = award_scene.instantiate()
	awards.add_child(award)
	award.resource = resource_
