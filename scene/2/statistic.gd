@tool
class_name Statistic extends PanelContainer


@export var minion: Minion
@export var refreshed: bool = false:
	set(refreshed_):
		refreshed = refreshed_
		
		if is_node_ready():
			for doublet in %Parameters.get_children():
				doublet.resource = doublet.resource
			for doublet in %Aspects.get_children():
				doublet.resource = doublet.resource
	get:
		return refreshed
@export var level: LevelResource

@onready var health = %HealthLimit
@onready var stamina = %StaminaLimit

@onready var damage_multiplier = %DamageMultiplier
@onready var damage_modifier = %DamageModifier
@onready var evasion_chance = %EvasionChance
@onready var accuracy_chance = %AccuracyChance
@onready var critical_multiplier = %CriticalMultiplier
@onready var critical_chance = %CriticalChance
@onready var armor_multiplier = %ArmorMultiplier
@onready var armor_modifier = %ArmorModifier
@onready var health_limit = %HealthLimit
@onready var stamina_limit = %StaminaLimit

@onready var strength_modifier = %Strength
@onready var dexterity_modifier = %Dexterity
@onready var intellect_modifier = %Intellect
@onready var will_modifier = %Will

@export var resource: StatisticResource

func _ready() -> void:
	refreshed = !refreshed
	resource = StatisticResource.new()
	
	roll_cores()
	recalc_doublet_values()
	
func roll_cores() -> void:
	level = LevelResource.new()
	#level.value = 1
	
	match minion.type:
		"mage":
			var rolls = [3, 2, 1, 0]
			var aspects = []
			aspects.append_array(Global.arr.aspect)
			aspects.shuffle()
			
			while !rolls.is_empty():
				var roll = rolls.pop_back()
				var aspect = aspects.pop_back()
				var core = level.get(aspect)
				core.current += roll
				#change_core_current(aspect, roll)
		#"monster":
		#	pass
	
#func change_core_current(type_: String, value_: int) -> void:
	#var index = Global.arr.aspect.find(type_)
	#var core = cores[index]
	#core.current += value_
	#
#func get_core_current(aspect_: String) -> int:
	#var index = Global.arr.aspect.find(aspect_)
	#var core = cores[index]
	#return core.current
	
func recalc_doublet_values() -> void:
	for parameter in Global.arr.parameter:
		update_doublet(parameter)
	
	for aspect in Global.arr.aspect:
		update_doublet(aspect + "_modifier")
	
func update_labels() -> void:
	for doublet in %Parameters.get_children():
		doublet.update_label()
	
	for doublet in %Aspects.get_children():
		doublet.update_label()
	
func update_doublet(title_: String) -> void:
	var doublet = get(title_)
	doublet.resource.value = resource.get_value(title_)
	
	if Global.arr.avg.has(title_):
		var words = title_.split("_")
		doublet.resource.value += level.get(words[0]).current
	
	doublet.update_label()
	
	if Global.arr.avg.has(title_):
		minion.library.recalc_avgs()
		minion.grimoire.recalc_avgs()
