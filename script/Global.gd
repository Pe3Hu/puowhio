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
	
func init_arr() -> void:
	arr.order = [0, 1, 2, 3, 4, 5, 6]
	arr.element = ["fire", "earth", "nature", "wind", "ice", "aqua", "storm", "lava"]
	arr.primordial = ["aqua", "fire", "wind", "earth"]
	arr.lateral = ["ice", "storm", "lava", "nature"]
	arr.aspect = ["strength", "dexterity", "intellect", "will"]
	arr.scroll = ["generator", "converter", "duplicator", "absorber"]
	arr.parameter = [
		"damage_multiplier", 
		"damage_modifier", 
		"evasion_chance",
		"accuracy_chance", 
		"critical_multiplier", 
		"critical_chance",
		"armor_multiplier", 
		"armor_modifier", 
		"health_limit", 
		"stamina_limit"
		]
	arr.aspect = ["strength", "dexterity", "intellect", "will"]
	arr.avg = [
		#"damage_modifier", 
		"strength_modifier", 
		"dexterity_modifier", 
		"intellect_modifier",
		"will_modifier",
		#"damage_multiplier", 
		"strength_multiplier", 
		"dexterity_multiplier", 
		"intellect_multiplier",
		"will_multiplier"
		]
	
	arr.terrain = ["swamp", "plain", "desert", "mountain", "tundra", "coast", "volcano", "jungle"]
	arr.resource = ["liquid", "gas", "ore"]
	arr.put = ["input", "output"]
	arr.trigger = ["wound", "critical", "dodge", "heal"]
	
	arr.status = ["buff", "debuff", "overtime"]
	arr.buff = ["boost", "protection", "flexibility", "fortune"]
	arr.debuff = ["weakness", "vulnerability", "blindness"]
	arr.overtime = ["flame", "poison", "regeneration", "dome"]
	arr.offensive = ["boost", "fortune", "weakness", "blindness"]
	arr.defensive = ["protection", "flexibility", "vulnerability"]
	
	arr.threat = ["offensive", "defensive"]
	arr.bowl = ["measure", "trigger", "side"]
	arr.evaluation = ["F", "E", "D", "C", "B", "A", "S"]
	arr.rarity = ["common", "uncommon", "rare", "epic", "legendary"]
	
	arr.titulus = ["earldom", "dukedom", "kingdom", "empire"]
	arr.windrose = ["N", "E", "S", "W"]
	
	
func init_num() -> void:
	num.index = {}
	num.index.fiefdom = 0
	num.index.earldom = 0
	num.index.dukedom = 0
	num.index.kingdom = 0
	num.index.empire = 0
	num.index.sector = 0
	
	num.trail = {}
	num.trail.min = 5
	num.trail.max = 7
	num.trail.best = 3
	num.trail.worst = 4
	
	num.biome = {}
	num.biome.n = 360 / 8
	
	num.thicket = {}
	num.thicket.limit = 10
	
	num.offset = {}
	num.grimoire = 68
	
func init_dict() -> void:
	init_direction()
	#init_avocation()
	init_state()
	
	init_affix()
	init_base()
	init_scroll()
	init_terrain()
	init_tier()
	init_trigram()
	init_book()
	init_monster()
	init_rarity()
	init_resource()
	init_evaluation()
	init_avocation()
	
func init_direction() -> void:
	dict.direction = {}
	dict.direction.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.direction.linear2 = [
		Vector2i( 0,-1),
		Vector2i( 1, 0),
		Vector2i( 0, 1),
		Vector2i(-1, 0)
	]
	dict.direction.diagonal = [
		Vector2i( 1,-1),
		Vector2i( 1, 1),
		Vector2i(-1, 1),
		Vector2i(-1,-1)
	]
	dict.direction.zero = [
		Vector2i( 0, 0),
		Vector2i( 1, 0),
		Vector2i( 1, 1),
		Vector2i( 0, 1)
	]
	dict.direction.hex = [
		[
			Vector2i( 1,-1), 
			Vector2i( 1, 0), 
			Vector2i( 0, 1), 
			Vector2i(-1, 0), 
			Vector2i(-1,-1),
			Vector2i( 0,-1)
		],
		[
			Vector2i( 1, 0),
			Vector2i( 1, 1),
			Vector2i( 0, 1),
			Vector2i(-1, 1),
			Vector2i(-1, 0),
			Vector2i( 0,-1)
		]
	]
	
	dict.direction.windrose = []
	
	for _i in dict.direction.linear2.size():
		var direction = dict.direction.linear2[_i]
		dict.direction.windrose.append(direction)
		direction = dict.direction.diagonal[_i]
		dict.direction.windrose.append(direction)
	
func init_state() -> void:
	dict.senor = {}
	dict.senor["earldom"] = "dukedom"
	dict.senor["dukedom"] = "kingdom"
	dict.senor["kingdom"] = "empire"
	
	dict.vassal = {}
	dict.vassal["dukedom"] = "earldom"
	dict.vassal["kingdom"] = "dukedom"
	dict.vassal["empire"] = "kingdom"
	
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
	dict.scroll.level = {}
	var exceptions = ["index"]
	
	var path = "res://asset/json/puowhio_scroll.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for scroll in array:
		scroll.index = int(scroll.index)
		scroll.level = int(scroll.level)
		var data = {}
		
		for key in scroll:
			if !exceptions.has(key):
				if key == "input" or key == "output":
					data[key] = []
					var masks = scroll[key].split(",")
					
					for mask in masks:
						data[key].append(int(mask))
				else:
					data[key] = scroll[key]
		
		dict.scroll.index[scroll.index] = data
		
		if !dict.scroll.type.has(scroll.type):
			dict.scroll.type[scroll.type] = []
		
		dict.scroll.type[scroll.type].append(scroll.index)
		
		if !dict.scroll.level.has(scroll.level):
			dict.scroll.level[scroll.level] = []
		
		dict.scroll.level[scroll.level].append(scroll.index)
	
func init_terrain() -> void:
	dict.sector = {}
	dict.sector.index = {}
	dict.terrain = {}
	dict.terrain.title = {}
	dict.terrain.element = {}
	dict.terrain.resource = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_terrain.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for terrain in array:
		var data = {}
		data.element = {}
		data.resource = {}
		
		for key in terrain:
			if !exceptions.has(key):
				if arr.element.has(key):
					if !dict.terrain.element.has(key):
						dict.terrain.element[key] = {}
					
					dict.terrain.element[key][terrain.title] = terrain[key]
					data.element[key] = terrain[key]
				elif arr.resource.has(key):
					if !dict.terrain.resource.has(key):
						dict.terrain.resource[key] = {}
					
					dict.terrain.resource[key][terrain.title] = terrain[key]
					data.resource[key] = terrain[key]
				else:
					var sectors = terrain[key].split(",")
					data[key] = []
					
					for sector in sectors:
						data[key].append(int(sector))
					
					for sector in data[key]:
						if !dict.sector.index.has(int(sector)):
							dict.sector.index[int(sector)] = []
						
						dict.sector.index[int(sector)].append(terrain.title)
			
		dict.terrain.title[terrain.title] = data
	
func init_tier() -> void:
	dict.tier = {}
	dict.tier.multiplier = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_tier.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for tier in array:
		tier.title = int(tier.title)
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
	
func init_book() -> void:
	dict.book = {}
	dict.book.level = {}
	dict.book.index = {}
	var exceptions = ["index", "level"]
	
	var path = "res://asset/json/puowhio_book.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	var abbreviations = {}
	abbreviations["i"] = "input"
	abbreviations["o"] = "output"
	
	for book in array:
		book.level = int(book.level)
		book.index = int(book.index)
		var data = {}
		
		for key in book:
			if !exceptions.has(key):
				var words = key.split(" ")
				
				if !data.has(words[0]):
					data[words[0]] = {}
				
				if words[0] == "scroll":
					data[words[0]][int(words[1])] = book[key]
				else:
					var order = int(book[key][0])
					
					if !data[words[0]].has(order):
						data[words[0]][order] = {}
					
					var put = abbreviations[book[key][1]]
					
					if !data[words[0]][order].has(put):
						data[words[0]][order][put] = []
					
					var mask = int(book[key][2])
					data[words[0]][order][put].append(mask)
			
		if !dict.book.level.has(book.level):
			dict.book.level[book.level] = []
	
		dict.book.level[book.level].append(book.index)
		dict.book.index[book.index] = data
	
func init_monster() -> void:
	dict.monster = {}
	dict.monster.title = {}
	dict.monster.terrain = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_monster.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for monster in array:
		var data = {}
		
		for key in monster:
			if !exceptions.has(key):
				var words = key.split(" ")
				
				if words.size() > 1:
					if !data.has(words[0]):
						data[words[0]] = {}
					
					data[words[0]][words[1]] = monster[key]
				else:
					data[words[0]] = monster[key]
			
		if !dict.monster.terrain.has(monster.terrain):
			dict.monster.terrain[monster.terrain] = []
	
		dict.monster.terrain[monster.terrain].append(monster.title)
		dict.monster.title[monster.title] = data
	
func init_rarity() -> void:
	dict.rarity = {}
	dict.rarity.title = {}
	dict.rarity.evaluation = {}
	dict.rarity.terrain = {}
	dict.rarity.mage = {}
	dict.rarity.monster = {}
	var exceptions = ["title", "level"]
	
	var path = "res://asset/json/puowhio_rarity.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for rarity in array:
		var data = {}
		
		for key in rarity:
			if !exceptions.has(key):
				var words = key.split(" ")
				
				if words.size() > 1:
					if words[1] == "aspect":
						if !data.has(words[1]):
							data[words[1]] = {}
						
						data[words[1]][words[0]] = rarity[key]
					else:
						if words[1] != "evaluation":
							if !dict.rarity[words[1]].has(rarity.title):
								dict.rarity[words[1]][rarity.title] = {}
							
							dict.rarity[words[1]][rarity.title][words[0]] = rarity[key]
						else:
							if !dict.rarity.has(words[1]):
								dict.rarity[words[1]] = {}
								
							if !dict.rarity[words[1]].has(words[0]):
								dict.rarity[words[1]][words[0]] = {}
							
							dict.rarity[words[1]][words[0]][rarity.title] = rarity[key]
				else:
					data[key] = rarity[key]
		
		dict.rarity.title[rarity.title] = data
	
func init_resource() -> void:
	dict.resource = {}
	dict.resource.index = {}
	dict.resource.source = {}
	dict.resource.type = {}
	var exceptions = ["index", "source"]
	
	var path = "res://asset/json/puowhio_resource.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for resource in array:
		resource.index = int(resource.index)
		var data = {}
		
		for key in resource:
			if !exceptions.has(key):
				data[key] = resource[key]
		
		dict.resource.index[resource.index] = data
		
		var sources = resource.source.split(",")
		
		for source in sources:
			if !dict.resource.source.has(source):
				dict.resource.source[source] = []
			
			dict.resource.source[source].append(resource.index)
		
		if !dict.resource.type.has(resource.type):
			dict.resource.type[resource.type] = []
		
		dict.resource.type[resource.type].append(resource.subtype)
	
func init_evaluation() -> void:
	dict.evaluation = {}
	dict.evaluation.title = {}
	dict.evaluation.weight = {}
	dict.evaluation.chance = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_evaluation.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for evaluation in array:
		var data = {}
		
		for key in evaluation:
			if !exceptions.has(key):
				dict.evaluation[key][evaluation.title] = evaluation[key]
		
		dict.evaluation.title[evaluation.title] = data
	
func init_avocation() -> void:
	dict.avocation = {}
	dict.avocation.title = {}
	dict.avocation.element = {}
	var exceptions = ["title"]
	
	var path = "res://asset/json/puowhio_avocation.json"
	var dictionary = load_data(path)
	var array = dictionary["blank"]
	
	for avocation in array:
		var data = {}
		
		for key in avocation:
			if !exceptions.has(key):
				var words = key.split(" ")
				
				if words.size() > 1:
					if !data.has(words[0]):
						data[words[0]] = {}
					
					data[words[0]][words[1]] = avocation[key]
				else:
					data[words[0]] = avocation[key]
		
		dict.avocation.title[avocation.title] = data
		
		if !dict.avocation.element.has(avocation.element):
			dict.avocation.element[avocation.element] = []
			
		dict.avocation.element[avocation.element].append(avocation.title)
	
func init_flag() -> void:
	flag.is_dragging = false
	
func init_vec():
	vec.size = {}
	vec.size.sixteen = Vector2(16, 16)
	vec.size.slot = Vector2(64, 64)
	
	init_window_size()
	
func init_window_size():
	vec.window = {}
	vec.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.window.center = Vector2(vec.window.width / 2, vec.window.height / 2)
	
func init_color():
	var h = 360.0
	
	color.aspect = {}
	color.aspect.strength = Color.from_hsv(0 / h, 0.6, 0.3)
	color.aspect.will = Color.from_hsv(60 / h, 0.6, 0.3)
	color.aspect.dexterity = Color.from_hsv(120 / h, 0.6, 0.3)
	color.aspect.intellect = Color.from_hsv(210 / h, 0.6, 0.3)
	
	color.element = {}
	#
	#for element in arr.element:
		#var _h = h / arr.element.size() * arr.element.find(element)
		#color.element[element] = Color.from_hsv(_h / h, 0.5, 0.8)
	
	color.element.fire = Color.from_hsv(0 / h, 0.7, 0.9)
	color.element.earth = Color.from_hsv(45 / h, 0.7, 0.9)
	color.element.nature = Color.from_hsv(90 / h, 0.7, 0.9)
	color.element.wind = Color.from_hsv(135 / h, 0.7, 0.9)
	color.element.ice = Color.from_hsv(180 / h, 0.7, 0.9)
	color.element.aqua = Color.from_hsv(225 / h, 0.7, 0.9)
	color.element.storm = Color.from_hsv(270 / h, 0.7, 0.9)
	color.element.lava = Color.from_hsv(315 / h, 0.7, 0.9)
	
	color.trigger = {}
	color.trigger.wound = Color.from_hsv(0 / h, 0.6, 0.3)
	color.trigger.critical = Color.from_hsv(270 / h, 0.6, 0.3)
	color.trigger.dodge = Color.from_hsv(120 / h, 0.6, 0.3)
	color.trigger.heal = Color.from_hsv(210 / h, 0.6, 0.3)
	
	color.side = {}
	color.side.done = Color.from_hsv(0 / h, 0.0, 0.2)
	color.side.taken = Color.from_hsv(0 / h, 0.0, 0.8)
	
	color.terrain = {}
	color.terrain.swamp = Color.from_hsv(65 / h, 0.6, 0.6)
	color.terrain.plain = Color.from_hsv(80 / h, 0.85, 0.85)
	color.terrain.desert = Color.from_hsv(45 / h, 0.85, 0.85)
	color.terrain.mountain = Color.from_hsv(230 / h, 0.6, 0.6)
	color.terrain.tundra = Color.from_hsv(180 / h, 0.6, 0.6)
	color.terrain.coast = Color.from_hsv(215 / h, 0.85, 0.85)
	color.terrain.volcano = Color.from_hsv(330 / h, 0.85, 0.85)
	color.terrain.jungle = Color.from_hsv(120 / h, 0.85, 0.85)
	
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
		if typeof(weights_[key]) == TYPE_INT:
			total += weights_[key]
		
		if typeof(weights_[key]) == TYPE_ARRAY:
			total += weights_[key].size()
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in weights_.keys():
		var weight = 0
		
		
		if typeof(weights_[key]) == TYPE_INT:
			weight = float(weights_[key])
		
		if typeof(weights_[key]) == TYPE_ARRAY:
			weight = float(weights_[key].size())
		
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null
	
func get_random_segment_point(extremes_):
	#if extremes_.keys().size() == 0:
	#if !extremes_.has("minimum") or !extremes_.has("maximum"):
		#print("!bug! empty dictionary in get_random_key func")
		#return null
	
	rng.randomize()
	var index_r = rng.randi_range(extremes_.minimum, extremes_.maximum)
	return index_r
