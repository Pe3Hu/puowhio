class_name NestedResource extends Resource



@export_enum("frame") var type = "frame"
@export_enum(
	"location"
	) var subtype: String = "location":
	set(subtype_):
		subtype = subtype_
	get:
		return subtype

@export var value: int: 
	set(value_):
		value = value_
	get:
		return value
