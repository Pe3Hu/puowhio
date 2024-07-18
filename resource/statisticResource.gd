class_name StatisticResource extends Resource


@export var damage_multiplier: int = 0
@export var damage_modifier: int = 0
@export var evasion_chance: int = 15
@export var accuracy_chance: int = 85
@export var critical_multiplier: int = 150
@export var critical_chance: int = 15
@export var armor_multiplier: int = 0
@export var armor_modifier: int = 0
@export var health_limit: int = 200
@export var stamina_limit: int = 100
@export var strength_multiplier: int = 100
@export var dexterity_multiplier: int = 100
@export var intellect_multiplier: int = 100
@export var will_multiplier: int = 100
@export var strength_modifier: int = 0
@export var dexterity_modifier: int = 0
@export var intellect_modifier: int = 0
@export var will_modifier: int = 0

@export var damage_multiplier_resources: Array[DoubletResource]
@export var damage_modifier_resources: Array[DoubletResource]
@export var evasion_chance_resources: Array[DoubletResource]
@export var accuracy_chance_resources: Array[DoubletResource]
@export var critical_multiplier_resources: Array[DoubletResource]
@export var critical_chance_resources: Array[DoubletResource]
@export var armor_multiplier_resources: Array[DoubletResource]
@export var armor_modifier_resources: Array[DoubletResource]
@export var health_limit_resources: Array[DoubletResource]
@export var stamina_limit_resources: Array[DoubletResource]
@export var strength_multiplier_resources: Array[DoubletResource]
@export var dexterity_multiplier_resources: Array[DoubletResource]
@export var intellect_multiplier_resources: Array[DoubletResource]
@export var will_multiplier_resources: Array[DoubletResource]
@export var strength_modifier_resources: Array[DoubletResource]
@export var dexterity_modifier_resources: Array[DoubletResource]
@export var intellect_modifier_resources: Array[DoubletResource]
@export var will_modifier_resources: Array[DoubletResource]


func get_value(title_: String) -> int:
	var title = str(title_)
	
	if Global.arr.aspect.has(title_):
		title +=  "_modifier"
	
	var value = round(get(title))
	var resources = get(title + "_resources")
	
	for resource in resources:
		value += resource.value
	
	return value
