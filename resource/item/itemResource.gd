class_name ItemResource extends Resource


@export_enum("trigram", "nucleus", "scroll") var type: String = "trigram":
	set(type_):
		type = type_
	get:
		return type
@export_enum("common", "uncommon", "rare", "epic", "legendary") var rarity: String = "uncommon":
	set(rarity_):
		rarity = rarity_
	get:
		return rarity

@export var level: int = 0:
	set(level_):
		level = level_
	get:
		return level
@export var index: int
@export var bases: Array[DoubletResource]
@export var affixs: Array[DoubletResource]
@export var masks: Dictionary
@export var kind: String
