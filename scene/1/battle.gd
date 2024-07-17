@tool
class_name Battle extends PanelContainer


@export var world: World

@export var current_mage: Mage

@export var turn: int = 0

@onready var mages = %Mages

@onready var mage_scene = preload("res://scene/1/mage.tscn")

var is_storing = false
var count = 1
var book_datas = []
var aspect_datas = []


func _ready() -> void:
	init_mages(0)
	#next_statistic_round()
	#current_mage.start_turn()

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
	
	await get_tree().process_frame
	#current_mage = mages.get_child(0)
	
	if is_storing:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", global_position, 0.1).set_ease(Tween.EASE_OUT)
		tween.tween_callback(get_statistics)
	
func get_statistics() -> void:
	var data = {}
	data.book = 0.0
	data.aspect = 0.0
	var aspects = []
	
	for aspect in Global.arr.aspect:
		aspects.append(aspect + "_modifier")
	
	for mage in mages.get_children():
		data.book += mage.grimoire.best_book.avg
		
		for aspect in aspects:
			data.aspect += mage.statistic.get(aspect).resource.value
	
	data.book /= mages.get_child_count()
	data.aspect /= mages.get_child_count()
	data.aspect /= Global.arr.aspect.size()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_callback(next_statistic_round)
	book_datas.append(data.book)
	aspect_datas.append(data.aspect)
	
func next_statistic_round() -> void:
	if is_storing:
		if count > 0:
			count -= 1
			init_mages(1)
		else:
			var path_ = "res://asset/json/avg_aspect.json"
			#var dictionary_as_string = JSON.parse_string(datas)
			var json_string = JSON.stringify(aspect_datas)
			Global.expand_file(path_, json_string)
