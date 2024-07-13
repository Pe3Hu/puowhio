extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var color = {}
var dict = {}
var flag = {}
var node = {}
var scene = {}
var tres = {}


func _ready() -> void:
	init_arr()
	init_num()
	init_vec()
	init_color()
	init_dict()
	init_flag()
	init_tres()


func init_arr() -> void:
	arr.element = ["fire", "earth", "nature", "wind", "ice", "aqua", "storm", "lava"]
	arr.aspect = ["strength", "dexterity", "intellect", "will"]
	arr.order = [0, 1, 2, 3, 4, 5, 6]


func init_num() -> void:
	num.index = {}


func init_dict() -> void:
	init_direction()
	
	init_affix()
	init_base()
	init_scroll()
	init_terrain()
	init_tier()
	init_trigram()
	
	dict.rarity = {}
	dict.rarity.affix = {}
	dict.rarity.affix["common"] = 0
	dict.rarity.affix["uncommon"] = 1
	dict.rarity.affix["rare"] = 2
	dict.rarity.affix["epic"] = 3
	dict.rarity.affix["legendary"] = 4


func init_direction() -> void:
	dict.direction = {}
	dict.direction.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.direction.linear2 = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	dict.direction.diagonal = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	dict.direction.zero = [
		Vector2( 0, 0),
		Vector2( 1, 0),
		Vector2( 1, 1),
		Vector2( 0, 1)
	]
	dict.direction.hex = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 0, 1), 
			Vector2(-1, 0), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 0),
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2( 0,-1)
		]
	]


func init_affix() -> void:
	dict.affix = {}
	dict.affix.title = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_affix.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for affix in array:
		var data = {}
		data.levels = {}
		
		for key in affix:
			if !exceptions.has(key):
				var words = key.split(" ")
				var level = int(words[1])
				
				if !data.levels.has(level):
					data.levels[level] = {}
				
				data.levels[level][words[0]] = affix[key]
			
		if !dict.affix.title.has(affix.title):
			dict.affix.title[affix.title] = []
	
		dict.affix.title[affix.title] = data.levels


func init_base() -> void:
	dict.base = {}
	dict.base.level = {}
	var exceptions = ["level"]
	
	var path = "res://asset/json/puowhio_base.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for base in array:
		base.level = int(base.level)
		var data = {}
		
		for key in base:
			if !exceptions.has(key):
				var words = key.split(" ")
				
				if !data.has(words[0]):
					data[words[0]] = {}
				
				data[words[0]][words[1]] = base[key]
			
		#if !dict.base.level.has(base.level):
			#dict.base.level[base.level] = []
	
		dict.base.level[base.level] = data


func init_scroll() -> void:
	dict.scroll = {}
	dict.scroll.index = {}
	dict.scroll.type = {}
	dict.scroll.rarity = {}
	var exceptions = []
	var index = 0
	
	var path = "res://asset/json/puowhio_scroll.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for scroll in array:
		var data = {}
		data.tier = {}
		
		for key in scroll:
			if !exceptions.has(key):
				var words = key.split(" ")
				
				if words.size() > 1:
					data[words[0]][words[1]] = scroll[key]
				else:
					data[key] = scroll[key]
		
		dict.scroll.index[index] = data
		
		if !dict.scroll.type.has(scroll.type):
			dict.scroll.type[scroll.type] = []
		
		dict.scroll.type[scroll.type].append(index)
		
		if !dict.scroll.rarity.has(scroll.rarity):
			dict.scroll.rarity[scroll.rarity] = []
		
		dict.scroll.rarity[scroll.rarity].append(index)
		
		index += 1


func init_terrain() -> void:
	dict.terrain = {}
	dict.terrain.title = {}
	dict.terrain.element = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_terrain.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for terrain in array:
		var data = {}
		
		for key in terrain:
			if !exceptions.has(key):
				data[key] = terrain[key]
				
				if terrain[key] > 0:
					if !dict.terrain.element.has(key):
						dict.terrain.element[key] = {}
					
					dict.terrain.element[key][terrain.title] = terrain[key]
			
		dict.terrain.title[terrain.title] = data


func init_tier() -> void:
	dict.tier = {}
	dict.tier.multiplier = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_tier.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for tier in array:
		var data = {}
		data.multiplier = {}
		
		for key in tier:
			if !exceptions.has(key):
				var words = key.split(" ")
				data[words[0]][words[1]] = tier[key]
		
		dict.tier.multiplier[tier.title] = data.multiplier


func init_trigram() -> void:
	dict.trigram = {}
	dict.trigram.parameter = {}
	dict.trigram.subtype = {}
	var exceptions = ["parameter"]
	
	var path = "res://asset/json/puowhio_trigram.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for trigram in array:
		var data = {}
		data.subtypes = {}
		
		for key in trigram:
			if !exceptions.has(key):
				var words = key.split(" ")
				var subtype = str(words[1])
				data.subtypes[subtype] = trigram[key]
				
				if !dict.trigram.subtype.has(subtype):
					dict.trigram.subtype[subtype] = {}
				
				dict.trigram.subtype[subtype][trigram.parameter] = trigram[key]
			
		dict.trigram.parameter[trigram.parameter] = data.subtypes


func init_flag() -> void:
	flag.is_dragging = false


func init_tres() -> void:
	for element in Global.arr.element:
		tres[element] = load("res://resource/orb/" + element + ".tres")


func init_vec():
	vec.size = {}
	vec.size.sixteen = Vector2(16, 16)
	vec.size.slot = Vector2(64, 64)
	
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	var h = 360.0
	
	color.aspect = {}
	color.aspect.strength = Color.from_hsv(0 / h, 0.6, 0.7)
	color.aspect.will = Color.from_hsv(60 / h, 0.6, 0.7)
	color.aspect.dexterity = Color.from_hsv(120 / h, 0.6, 0.7)
	color.aspect.intellect = Color.from_hsv(210 / h, 0.6, 0.7)
	
	color.element = {}
	
	for element in arr.element:
		var _h = h / arr.element.size() * arr.element.find(element)
		color.element[element] = Color.from_hsv(_h / h, 0.6, 0.7)


func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var _parse_err = json_object.parse(text)
	return json_object.get_data()


func get_random_key(weights_: Dictionary):
	if weights_.keys().size() == 0:
		print("!bug! empty dictionary in get_random_key func")
		return null
	
	var total = 0
	
	for key in weights_.keys():
		total += weights_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in weights_.keys():
		var weight = float(weights_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null


func get_random_segment_point(extremes_: Dictionary):
	if extremes_.keys().size() == 0:
		print("!bug! empty dictionary in get_random_key func")
		return null
	
	rng.randomize()
	var index_r = rng.randi_range(extremes_.minimum, extremes_.maximum)
	return index_r
