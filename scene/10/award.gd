extends PanelContainer


@export var sprite: Sprite2D
@export var resource: AwardResource:
	set(resource_):
		resource = resource_
		update_spite()
	get:
		return resource

@onready var essence_image = preload("res://asset/png/resource/essence.png")
@onready var fragment_image = preload("res://asset/png/resource/fragment.png")
@onready var recipe_image = preload("res://asset/png/resource/recipe.png")
@onready var trophy_image = preload("res://asset/png/resource/trophy.png")


func update_spite() -> void:
	sprite.texture = get(resource.type + "_image")
	sprite.vframes = Global.dict.resource.type[resource.type].size()
	sprite.frame = Global.dict.resource.type[resource.type].find(resource.subtype)
	var a = Global.dict.rarity.title[resource.rarity]
	sprite.modulate = Global.dict.rarity.title[resource.rarity].color
