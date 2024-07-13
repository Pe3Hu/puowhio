
class_name Nexus extends PanelContainer


@onready var item_scene = preload("res://scene/4/item.tscn")

func generate_item(resource_: ItemResource) -> Item:
	var item = item_scene.instantiate()
	add_child(item)
	item.resource = resource_
	remove_child(item)
	
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
	
	item.description.init_doublets()
	return item
	#var slot = free_slots.pop_back()
	#occupied_slots.append(slot)
	#slot.item = item
