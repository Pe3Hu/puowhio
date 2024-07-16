@tool
class_name OrbResource extends Resource


@export_enum("aqua", "wind", "fire", "earth", "ice", "storm", "lava", "nature") var element: String = "aqua":
	set(element_):
		element = element_
		
	get:
		return element

@export var texture: Texture

@export var color: Color


