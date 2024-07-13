@tool
class_name Slot extends PanelContainer


@export var item: Item:
	set(item_):
		item = item_
		item.slot = self
		
		if is_node_ready():
			item.move_to_initial_position(0)
	get:
		return item

@export_enum("any", "trigram", "nucleus") var type: String = "any":
	set(type_):
		type = type_
		
		if is_node_ready():
			refresh_background()
	get:
		return type

@export_enum("0", "1", "2", "3", "4", "5", "6", "7") var subtype: String = "0":
	set(subtype_):
		subtype = subtype_
		
		if is_node_ready():
			refresh_background()
	get:
		return subtype

@onready var collision_shape = $StaticBody2D/CollisionShape2D


func refresh_background() -> void:
	if type == "any":
		%Background.frame = 9
	if type == "trigram":
		%Background.frame = int(subtype)
	if type == "nucleus":
		%Background.frame = 8
