@tool
class_name Battle extends PanelContainer


@export var world: World
@export var observer: Observer
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
var initiatives: Array[Minion]
var winner: Minion
var loser: Minion


func _ready() -> void:
	pass
	#init_mages(2)
	#init_monsters(2)
	#prepare()
	
	await get_tree().process_frame
	await get_tree().process_frame
	for _i in 0:
		pass_initiative()
	
func init_mages(count_: int) -> void:
	while mages.get_child_count() > 0:
		var mage = mages.get_child(0)
		mages.remove_child(mage)
		mage.queue_free()
	
	for _i in count_:
		var mage = mage_scene.instantiate()
		mage.battle = self
		mages.add_child(mage)
		initiatives.append(mage)
		mage.inventory.roll_starter_items()
		mage.library.roll_starter_items()
		mage.init_threats()
		mage.reset()
	
func init_monsters(count_: int) -> void:
	while monsters.get_child_count() > 0:
		var monster = monsters.get_child(0)
		monsters.remove_child(monster)
		monster.queue_free()
	
	for _i in count_:
		var monster = monster_scene.instantiate()
		monster.battle = self
		monster.terrain = "swamp"
		monsters.add_child(monster)
		initiatives.append(monster)
		monster.roll_kind()
		monster.library.roll_starter_items()
		monster.bowl.init_resource()
		monster.init_threats()
		monster.reset()
	
func prepare() -> void:
	observer.reset()
	initiatives.shuffle()
	
	for minion in initiatives:
		minion.reset()
		minion.is_combat = true
	
	initiatives[0].enemy = initiatives[1]
	initiatives[1].enemy = initiatives[0]
	observer.passive = initiatives[0]
	observer.active = initiatives[1]
	
func pass_initiative() -> void:
	if winner == null:
		var index = (initiatives.find(observer.active) + 1) % initiatives.size()
		observer.passive = observer.active
		observer.active = initiatives[index]
		observer.active.start_turn()
	
func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					pass_initiative()
