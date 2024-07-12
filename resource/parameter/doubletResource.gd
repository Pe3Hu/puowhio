class_name DoubletResource extends Resource



@export_enum("percentage", "integer") var measure = "percentage"
@export_enum("parameter", "aspect") var type = "parameter"
@export_enum("permanent", "temporary") var time = "permanent"

@export var icon_name: String:
	set(icon_name_):
		icon_name = icon_name_
	get:
		return icon_name

@export var base: int: 
	set(base_):
		base = base_
	get:
		return base
