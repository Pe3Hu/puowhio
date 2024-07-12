@tool
class_name Orb extends PanelContainer


@export var resource: OrbResource:
	set(resource_):
		resource = resource_
		
		if is_node_ready():
			
			%TextureRect.custom_minimum_size = base_size
			%TextureRect.size = base_size
			%TextureRect.texture = resource.texture
			%TextureRect.modulate = resource.color
	get:
		return resource

@export var cell_size: Vector2 = base_size:
	set(cell_size_):
		cell_size = cell_size_
		
		if is_node_ready():
			custom_minimum_size = cell_size
	get:
		return cell_size

const base_size = Vector2(32, 32)

@onready var tRect = %TextureRect
