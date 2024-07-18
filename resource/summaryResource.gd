class_name SummaryResource extends Resource


@export_enum("common", "uncommon", "rare", "epic", "legendary") var rarity: String = "uncommon":
	set(rarity_):
		rarity = rarity_
	get:
		return rarity
@export var kind: String:
	set(kind_):
		kind = kind_
		
		var description = Global.dict.monster.title[kind]
		status = description.status
		style = description.style
		parameter = description.parameter
		
		primary.subtype = description.primary.aspect
		primary.value = description.primary.weight
		secondary.subtype = description.secondary.aspect
		secondary.value = description.secondary.weight
		
		bowl.measure = description.bowl.measure
		bowl.trigger = description.bowl.trigger
		bowl.side = description.bowl.side
		pass
	get:
		return kind
@export var status: String
@export var style: String
@export var parameter: String
@export var bowl: BowlResource
@export var primary: DoubletResource
@export var secondary: DoubletResource


func _init() -> void:
	bowl = BowlResource.new()
	primary = DoubletResource.new()
	secondary = DoubletResource.new()
	#primary.measure = 
