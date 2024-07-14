@tool
class_name Slot extends PanelContainer


@export var proprietor: PanelContainer

@export var orb: Orb:
	set(orb_):
		orb = orb_
		orb.slot = self
		
		if is_node_ready():
			orb.move_to_slot_position(0)
	get:
		return orb

@export var item: Item:
	set(item_):
		item = item_
		item.slot = self
		
		if is_node_ready():
			item.move_to_initial_position(0)
	get:
		return item

@export var texture_size: Vector2:
	set(texture_size_):
		texture_size = texture_size_
		
		if is_node_ready():
			custom_minimum_size = texture_size
			size = texture_size
			%Background.position = texture_size / 2
			%Background.scale = texture_size / (Vector2.ONE * 64)
			%CollisionShape2D.position = texture_size / 2
			%CollisionShape2D.scale = texture_size / (Vector2.ONE * 64)
	get:
		return texture_size

@export_enum("any", "trigram", "nucleus", "scroll", "orb") var type: String = "any":
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


func _ready() -> void:
	texture_size = texture_size
	refresh_background()

func refresh_background() -> void:
	if type == "any":
		%Background.frame = 9
	if type == "trigram":
		%Background.frame = int(subtype)
	if type == "nucleus":
		%Background.frame = 8
	if type == "scroll":
		%Background.frame = 10
	if type == "orb":
		%Background.frame = 11
		texture_size = Vector2.ONE * 32

func check_type(item_: Item) -> bool:
	if type == "any":
		if item_.resource.type == "trigram" or item_.resource.type == "nucleus":
			return true
	
	if item_.resource.type != type:
		return false
	
	if item_.resource.type == "trigram":
		if item_.resource.subtype != subtype:
			return false
	
	return true
