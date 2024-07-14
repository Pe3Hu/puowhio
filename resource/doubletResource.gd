class_name DoubletResource extends Resource


@export_enum("percentage", "integer") var measure = "percentage"
@export_enum("parameter", "aspect") var type = "parameter"
@export_enum("permanent", "temporary") var time = "permanent"

@export var subtype: String:
	set(subtype_):
		subtype = subtype_
	get:
		return subtype

@export var value: int: 
	set(value_):
		value = value_
	get:
		return value
