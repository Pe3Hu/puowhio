@tool
class_name Battle extends PanelContainer


@export var world: World
@export var current_minion: Minion
@export var turn: int = 0

@onready var minions = %Minions
@onready var mages = %Mages
@onready var monsters = %Monsters
@onready var monster_scene = preload("res://scene/1/monster.tscn")
@onready var mage_scene = preload("res://scene/1/mage.tscn")

var is_storing = false
var count = 1
var book_datas = []
var aspect_datas = []


func _ready() -> void:
	pass
	#init_mages(1)
	#init_monsters(1)
	
func init_mages(count_: int) -> void:
	while mages.get_child_count() > 0:
		var mage = mages.get_child(0)
		mages.remove_child(mage)
		mage.queue_free()
	
	for _i in count_:
		var mage = mage_scene.instantiate()
		mage.battle = self
		mages.add_child(mage)
		mage.reset()
	
func init_monsters(count_: int) -> void:
	while monsters.get_child_count() > 0:
		var monster = monsters.get_child(0)
		monsters.remove_child(monster)
		monster.queue_free()
	
	for _i in count_:
		var monster = monster_scene.instantiate()
		monster.battle = self
		monsters.add_child(monster)
		monster.terrain = "swamp"
		monster.reset()
