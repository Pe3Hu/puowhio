class_name ItemResource extends Resource


@export_enum("trigram", "nucleus") var type: String = "trigram":
	set(type_):
		type = type_
	get:
		return type

@export_enum("0", "1", "2", "3", "4", "5", "6", "7") var subtype: String = "0":
	set(subtype_):
		subtype = subtype_
	get:
		return subtype

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

@export var bases: Array[BaseResource]

@export var affixs: Array[AffixResource]
