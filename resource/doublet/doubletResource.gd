class_name DoubletResource extends Resource


@export_enum("permanent", "temporary") var time = "permanent"
@export_enum("limit", "modifier", "chance", "multiplier") var measure = "modifier"
@export_enum("parameter", "aspect", "threat") var type = "parameter"
@export_enum(
	"damage", "evasion", "accuracy", "critical", "armor", "health", "stamina",
	"strength", "dexterity", "intellect", "will",
	"offensive", "defensive"
	) var subtype: String = "damage":
	set(subtype_):
		subtype = subtype_
	get:
		return subtype

@export var value: int: 
	set(value_):
		value = value_
	get:
		return value
