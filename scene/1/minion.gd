@tool
class_name Minion extends PanelContainer


@export_enum("mage", "monster") var type: String
@export var hsm: LimboHSM
@export var battle: Battle
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
@export var is_active: bool = false


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
	print(battle.turn)
	
func start_turn() -> void:
	is_active = true
	hsm.dispatch(&"searching_started")
	
func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					start_turn()
