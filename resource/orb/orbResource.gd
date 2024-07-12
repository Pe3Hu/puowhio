@tool
class_name OrbResource extends Resource


@export_enum("aqua", "wind", "fire", "earth", "ice", "storm", "lava", "nature") var aspect: String = "aqua":
	set(aspect_):
		aspect = aspect_
		
	get:
		return aspect

@export var texture: Texture

@export var color: Color


