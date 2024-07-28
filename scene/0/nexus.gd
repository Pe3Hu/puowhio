@tool
class_name Nexus extends PanelContainer


@onready var trigram_scene = preload("res://scene/5/trigram.tscn")
@onready var totem_scene = preload("res://scene/5/totem.tscn")
@onready var scroll_scene = preload("res://scene/5/scroll.tscn")
@onready var prize_scene = preload("res://scene/10/prize.tscn")


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
	var extremes = Global.dict.level.index[resource_.level][resource_.type]
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
		var resource = DoubletResource.new()
		resource.subtype = aspect
		resource.value = bases[aspect]
		resource_.bases.append(resource)
	
	if resource_.type == "trigram":
		count = Global.dict.rarity.title[resource_.rarity].affix
		
		if count > 0:
			weights = Global.dict.trigram.subtype[resource_.subtype]
			
			for _i in count:
				var parameter = Global.get_random_key(weights)
				weights.erase(parameter)
				extremes = Global.dict.affix.title[parameter][resource_.level]
				var words = parameter.split(" ")
				
				var resource = DoubletResource.new()
				resource.subtype = words[0]
				resource.measure = words[1]
				resource.value = Global.get_random_segment_point(extremes)
				resource_.affixs.append(resource)
	
func roll_totem(resource_: ItemResource) -> void:
	roll_trigram(resource_)
	
func roll_scroll(resource_: ItemResource) -> void:
	var indexs = Global.dict.scroll.level[resource_.level].filter(func(index): return Global.dict.scroll.index[index].type == resource_.subtype)
	#indexs = indexs
	resource_.index = indexs.front()
	resource_.tier = Global.dict.scroll.index[resource_.index].tier
	var extremes = Global.dict.tier.multiplier[resource_.tier]
	resource_.multiplier = Global.get_random_segment_point(extremes)
	
	var resource = DoubletResource.new()
	resource.subtype = "damage"
	resource.measure = "multiplier"
	resource.value = resource_.multiplier
	resource_.affixs.append(resource)
	
	roll_aspects(resource_)
	roll_orbs(resource_)
	
func roll_aspects(resource_: ItemResource)  -> void:
	var options = []
	var n = 2
	
	if resource_.kind != "":
		var description = Global.dict.monster.title[resource_.kind]
		options.append(description.primary.aspect)
		options.append(description.secondary.aspect)
	else:
		options.append_array(Global.arr.aspect)
		options.shuffle()
		
		while options.size() > n:
			options.pop_back()
	
	var shares = []
	var sum = 0
	var remainder = 100.0
	
	for _i in options.size():
		var share = n - _i
		shares.append(share)
		sum += share
	
	#print()
	
	Global.rng.randomize()
	var gap = Global.rng.randf_range(-0.5, 0.5)
	shares[0] += gap
	shares[1] -= gap
	var measure = remainder / sum
	
	for _i in n:
		var resource = DoubletResource.new()
		resource.type = "aspect"
		resource.measure = "multiplier"
		resource.subtype = options.pop_front()
		resource.value = round(shares[_i] * measure)
		resource_.aspects.append(resource)
	
func roll_orbs(resource_: ItemResource)  -> void:
	if !resource_.masks.is_empty():
		var description = Global.dict.scroll.index[resource_.index]
		var signs = {}
		signs["input"] = -1
		signs["output"] = 1
		
		for put in resource_.masks:
			for mask_index in description[put]:
				var element = resource_.masks[put][mask_index]
				resource_.equilibrium.change(element, signs[put])
	else:
		var n = 1
		
		match resource_.subtype:
			"generator":
				resource_.output_limit = n
			"converter":
				resource_.input_limit = n
				resource_.output_limit = n
			"absorber":
				resource_.input_limit = n
		
		var options = []
		options.append_array(resource_.prioritized_elements)
		
		for _i in resource_.input_limit:
			if options.is_empty():
				options.append_array(Global.arr.primordial)
				
				for element in resource_.prioritized_elements:
					options.erase(element)
			
			var element = options.pick_random()
			
			match resource_.subtype:
				"converter":
					options.erase(element)
				"duplicator":
					options = [element]
			
			resource_.equilibrium.change(element, -1)
		
		for _i in resource_.output_limit:
			if options.is_empty():
				options.append_array(Global.arr.primordial)
				
				for element in resource_.prioritized_elements:
					options.erase(element)
			
			var element = options.pick_random()
			resource_.equilibrium.change(element, 1)
	
	#print([resource_.subtype, resource_.input_orbs, resource_.output_orbs])
	pass
	
func generate_prize() -> void:
	var description = Global.dict.evaluation
	var fund = 110
	var source_ = "monster"
	var evaluations = []
	
	var prize = prize_scene.instantiate()
	add_child(prize)
	#remove_child(prize)
	
	while fund > 0:
		var chances = description.chance.duplicate()
		
		for _evaluation in description.weight:
			if description.weight[_evaluation] > fund or evaluations.has(_evaluation):
				chances.erase(_evaluation)
		
		if !chances.is_empty():
			var evaluation = Global.get_random_key(chances)
			evaluations.append(evaluation)
			fund -= description.weight[evaluation]
		else:
			fund = 0
	
	evaluations.sort_custom(func(a, b): return Global.arr.evaluation.find(a) > Global.arr.evaluation.find(b))
	
	for evaluation in evaluations:
		var resource = AwardResource.new()
		resource.source = source_
		var chances = Global.dict.rarity.evaluation[evaluation.to_lower()]
		resource.rarity = Global.get_random_key(chances)
		chances = Global.dict.rarity.minion[resource.rarity]
		resource.type = Global.get_random_key(chances)
		print([evaluation, resource.rarity, resource.type, resource.subtype])
		prize.add_award(resource)
