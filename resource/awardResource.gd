class_name AwardResource extends Resource


@export_enum("monster", "mage", "terrain") var source
@export_enum("recipe", "fragment", "essence", "trophy") var type:
	set(type_):
		type = type_
		roll_subtype()
	get:
		return type
@export_enum("trigram", "totem", "scroll", 
	"ore", "liquid", "gas", 
	"bone", "blood", "skin", "heart"
	) var subtype
@export_enum("common", "uncommon", "rare", "epic", "legendary") var rarity

@export var index: int


func roll_subtype() -> void:
	var options = Global.dict.resource.source[source].filter(func(a): return Global.dict.resource.index[a].type == type)# and Global.dict.resource.index[a].source == source
	var weights = {}
	
	for option in options:
		weights[option] = Global.dict.resource.index[option].chance
	
	index = Global.get_random_key(weights)
	subtype = Global.dict.resource.index[index].subtype
