class_name SummaryResource extends Resource


@export_enum("common", "uncommon", "rare", "epic", "legendary") var rarity: String = "uncommon":
	set(rarity_):
		rarity = rarity_
	get:
		return rarity
@export var kind: String:
	set(kind_):
		kind = kind_
		
		if Global.dict.has("monster"):
			var description = Global.dict.monster.title[kind]
			style = description.style
			parameter = description.parameter
			
			primary.subtype = description.primary.aspect
			primary.value = description.primary.weight
			secondary.subtype = description.secondary.aspect
			secondary.value = description.secondary.weight
			
			#bowl.measure = description.bowl.measure
			#bowl.trigger = description.bowl.trigger
			#bowl.side = description.bowl.side
			#
			#status.resource.type  = description.status.type
			#status.resource.stack_value  = description.status.value
			#status.resource.stack_step  = description.status.step
			pass
	get:
		return kind
@export var aspects: int
@export var style: String
@export var parameter: String
#@export var bowl: BowlResource
#@export var status: StatusResource
@export var primary: DoubletResource
@export var secondary: DoubletResource


func _init() -> void:
	#bowl = BowlResource.new()
	#status = StatusResource.new()
	primary = DoubletResource.new()
	secondary = DoubletResource.new()
	#primary.measure = 
