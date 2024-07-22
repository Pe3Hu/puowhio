@tool
class_name Minion extends PanelContainer


@export_enum("mage", "monster") var type: String
@export var hsm: LimboHSM
@export var battle: Battle
@export var enemy: Minion
@export var statistic: Statistic:
	set(statistic_):
		statistic = statistic_
		statistic.minion = self
	get:
		return statistic
@export var conveyor: Conveyor:
	set(conveyor_):
		conveyor = conveyor_
		conveyor.minion = self
	get:
		return conveyor
@export var grimoire: Grimoire:
	set(grimoire_):
		grimoire = grimoire_
		grimoire.minion = self
	get:
		return grimoire
@export var library: Library:
	set(library_):
		library = library_
		library.minion = self
	get:
		return library
@export var aura: Aura:
	set(aura_):
		aura = aura_
		aura.minion = self
	get:
		return aura
@export var health: Bar:
	set(health_):
		health = health_
		health.proprietor = self
	
		if is_node_ready():
			health.limit = statistic.health.value
	get:
		return health
@export var stamina: Bar:
	set(stamina_):
		stamina = stamina_
		stamina.proprietor = self
	
		if is_node_ready():
			stamina.limit = statistic.stamina.value
	get:
		return stamina
@export var offensive: Doublet
@export var defensive: Doublet
@export var is_active: bool = false
@export var is_combat: bool = false:
	set(is_combat_):
		is_combat = is_combat_
		
		if is_node_ready():
			library.slots.visible = !is_combat
			
			for slot in grimoire.slots.get_children():
				if slot.item == null:
					slot.visible = !is_combat
			
			for scroll in library.unsloted_scrolls:
				scroll.visible = !is_combat
			
			if is_combat:
				%ScrollsVBox.set("theme_override_constants/separation", 0)
			else:
				%ScrollsVBox.set("theme_override_constants/separation", Global.num.grimoire)
	get:
		return is_combat

var bowsl: Array[Bowl]


func init_threats() -> void:
	for subtype in Global.arr.threat:
		var doublet = get(subtype)
		doublet.resource = DoubletResource.new()
		doublet.resource.type = "threat"
		doublet.resource.subtype = subtype
		doublet.resource.measure = "limit"
		doublet.resource.value = 0
		doublet.update_ui()
		
		if grimoire.best_book != null and subtype == "offensive":
			doublet.resource.value = grimoire.best_book.cycle_avg
		
		doublet.update_label()
	
func reset() -> void:
	health.limit = statistic.health.resource.value
	health.value = health.limit
	health.tempo = "standard"
	
	stamina.limit = statistic.stamina.resource.value
	stamina.value = stamina.limit
	stamina.tempo = "standard"
	
func call_pass() -> void:
	if is_active:
		battle.turn += 1
		print("Turn " + str(battle.turn))
		#hsm.dispatch(&"searching_started")
	
func concede_defeat() -> void:
	battle.loser = self
	battle.winner = enemy
	print("Victory on ", battle.turn)
	
func start_turn() -> void:
	is_active = true
	hsm.dispatch(&"searching_started")
	
func update_threat(subtype_: String) -> void:
	pass
	
func declare_bowls() -> void:
	for bowl in bowsl:
		for resource in battle.observer.bowls:
			if resource.is_equal(bowl.resource):
				battle.observer.bowls[resource].append(bowl)
