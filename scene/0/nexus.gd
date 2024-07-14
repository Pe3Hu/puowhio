@tool
class_name Nexus extends PanelContainer


@onready var trigram_scene = preload("res://scene/5/trigram.tscn")
@onready var nucleus_scene = preload("res://scene/5/nucleus.tscn")
@onready var scroll_scene = preload("res://scene/5/scroll.tscn")


func generate_item(resource_: ItemResource) -> Item:
	var item = get(resource_.type + "_scene").instantiate()
	add_child(item)
	item.resource = resource_
	remove_child(item)
	
	call("roll_" + resource_.type, resource_)
	item.description.init_doublets()
	
	if resource_.type == "scroll":
		item.description.init_orbs()
		item.description.damage.visible = true
	
	return item
	
func roll_trigram(resource_: ItemResource) -> void:
	var extremes = Global.dict.base.level[resource_.level][resource_.type]
	var count = Global.get_random_segment_point(extremes)
	var weights = {}
	var bases = {}
	var affixs = {}
	
	for aspect in Global.arr.aspect:
		weights[aspect] = 1
	
	while count > 0:
		var aspect = Global.get_random_key(weights)
		weights[aspect] += 2
		Global.rng.randomize()
		var value = Global.rng.randi_range(1, count)
		
		if !bases.has(aspect):
			bases[aspect] = 0
		
		bases[aspect] += value
		count -= value
	
	for aspect in bases:
		var resource = BaseResource.new()
		resource.aspect = aspect
		resource.value = bases[aspect]
		resource_.bases.append(resource)
	
	if resource_.type == "trigram":
		count = Global.dict.rarity.affix[resource_.rarity]
		
		if count > 0:
			weights = Global.dict.trigram.subtype[resource_.subtype]
			
			for _i in count:
				var parameter = Global.get_random_key(weights)
				weights.erase(parameter)
				extremes = Global.dict.affix.title[parameter][resource_.level]
				
				var resource = AffixResource.new()
				resource.parameter = parameter
				resource.value = Global.get_random_segment_point(extremes)
				resource_.affixs.append(resource)
	
func roll_nucleus(resource_: ItemResource) -> void:
	roll_trigram(resource_)
	
func roll_scroll(resource_: ItemResource) -> void:
	var options = Global.dict.scroll.type[resource_.subtype]
	var index = options.front()
	var extremes = Global.dict.scroll.index[index].tier
	resource_.tier = Global.get_random_segment_point(extremes)
	extremes = Global.dict.tier.multiplier[resource_.tier]
	resource_.multiplier = Global.get_random_segment_point(extremes)
	
	var resource = AffixResource.new()
	resource.parameter = "damage multiplier"
	resource.value = resource_.multiplier
	resource_.affixs.append(resource)
	
	roll_aspects(resource_)
	roll_orbs(resource_)
	
func roll_aspects(resource_: ItemResource)  -> void:
	var n = 2
	var options = []
	options.append_array(Global.arr.aspect)
	options.shuffle()
	var shares = []
	var sum = 0
	var remainder = 100.0
	
	for _i in n:
		var share = n - _i
		shares.append(share)
		sum += share
	
	var measure = remainder / sum
	
	for _i in n:
		var aspect = options.pop_front()
		var resource = load("res://resource/share/" + aspect + ".tres")
		#var resource = aspect_resource.insi
		resource.value = round(shares[_i] * measure)
		resource_.aspects.append(resource)
	
func roll_orbs(resource_: ItemResource)  -> void:
	var n = 1
	
	match resource_.subtype:
		"generator":
			resource_.output_limit = 1
		"converter":
			pass
		"duplicator":
			pass
		"absorber":
			resource_.input_limit = 1
	
	for _i in resource_.input_limit:
		var element = Global.arr.element.pick_random()
		resource_.input_orbs.append(element)
		
		if !resource_.demands.has(element):
			resource_.demands[element] = 0
			
		resource_.demands[element] += 1
	
	for _i in resource_.output_limit:
		var element = Global.arr.element.pick_random()
		resource_.input_orbs.append(element)
