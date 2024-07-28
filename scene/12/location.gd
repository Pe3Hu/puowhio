class_name Location extends PanelContainer


@export var fiefdom: Fiefdom
#@export var territory: Territory
@export var index: Nested

@export var elements: VBoxContainer
@export var monsters: VBoxContainer
@export var troves: VBoxContainer
@export var dangers: VBoxContainer

@onready var record_scene = preload("res://scene/0/record.tscn")

var populations = {}
var abundances = {}


func _ready() -> void:
	init_nesteds()
	init_elements()
	init_monsters()
	init_dangers()
	init_troves()
	
func init_nesteds() -> void:
	var resource = NestedResource.new()
	resource.value = fiefdom.resource.index
	index.set_from_nested(resource)
	index.icon.modulate = Global.color.terrain[fiefdom.biome.terrain]
	
func init_elements() -> void:
	var weights = Global.dict.terrain.title[fiefdom.biome.terrain].element
	var _elements = weights.keys()
	_elements.sort_custom(func(a, b): return weights[a] > weights[b])
	
	for element in _elements:
		if weights[element] > 0:
			var multiplier = "x" + str((float(weights[element] + 100) / 100))
			var record = record_scene.instantiate()
			record.set_label_text("first", element)
			record.set_label_text("second", multiplier)
			elements.add_child(record)
	
func init_monsters() -> void:
	var probabilities = [6,5,4,3,2]
	var sum = 20
	var kinds = Global.dict.monster.terrain[fiefdom.biome.terrain].duplicate()
	kinds.shuffle()
	
	for _i in kinds.size():
		var kind = kinds[_i]
		var probability = str(floor(float(probabilities[_i]) / sum * 100)) + "%"
		var record = record_scene.instantiate()
		record.set_label_text("first", kind)
		record.set_label_text("second", probability)
		monsters.add_child(record)
		populations[kinds] = probabilities[_i] * 10
	
func init_dangers() -> void:
	if fiefdom.thicket != -1:
		var weights = Global.dict.level.index[fiefdom.thicket].danger
		
		for danger in weights:
			if weights[danger] > 0:
				var probability = str(weights[danger]) + "%"
				var record = record_scene.instantiate()
				record.set_label_text("first", "danger " + str(danger + fiefdom.thicket))
				record.set_label_text("second", probability)
				dangers.add_child(record)
	
func init_troves() -> void:
	var weights = Global.dict.terrain.title[fiefdom.biome.terrain].resource
	var limit = 50
	var counter = int(limit)
	
	for essence in weights:
		abundances[essence] = 0
	
	while counter > 0:
		var essence = Global.get_random_key(weights)
		Global.rng.randomize()
		var value = Global.rng.randi_range(1, max(counter / 8, 1))
		counter -= value
		abundances[essence] += value
	
	var _essences = abundances.keys()
	_essences.sort_custom(func(a, b): return abundances[a] > abundances[b])
	
	for essence in _essences:
		if abundances[essence] > 0:
			var probability = str(floor(float(abundances[essence]) / limit * 100)) + "%"
			var record = record_scene.instantiate()
			record.set_label_text("first", essence)
			record.set_label_text("second", probability)
			troves.add_child(record)
#func init_nesteds() -> void:
	#var keys = ["index"]#, "terrain"]
	#
	#for key in keys:
		#var nested = get(key)
		#var resource = NestedResource.new()
		#
		#match key:
			#"index":
				#resource.value = fiefdom.resource.index
		#
		#nested.set_from_nested(resource)
