class_name Library extends PanelContainer


@export var minion: Minion
@export var scrolls: PanelContainer

@onready var slots = %Slots

var free_slots: Array[Slot]
var occupied_slots: Array[Slot]


func _ready() -> void:
	for slot in %Slots.get_children():
		free_slots.push_front(slot)
		slot.refresh_background()
	
	#roll_starter_items()
	
func roll_starter_items() -> void:
	if false:
		return
	
	var nexus = minion.battle.world.nexus
	
	match minion.type:
		"mage":
			var subtypes = ["generator", "converter", "absorber"]
			
			for subtype in subtypes:
				var prioritized_elements = []
				prioritized_elements.append_array(Global.arr.primordial)
				prioritized_elements.shuffle()
				
				for _j in 3:
					var resource = ScrollResource.new()
					resource.rarity = "common"
					resource.level = 1
					resource.type = "scroll"
					resource.subtype = subtype
					var element = prioritized_elements.pop_back()
					resource.prioritized_elements.append(element)
					#resource.equilibrium = EquilibriumResource.new()
					var item = nexus.generate_item(resource)
					add_item(item)
		"monster":
			var options = Global.dict.book.level[minion.statistic.level.value]
			var index = 1#options.pick_random()
			var prioritizeds = Global.dict.terrain.title[minion.terrain].element
			var masks = {}
			var book_description = Global.dict.book.index[index]
			
			for _i in book_description.mask:
				for put in book_description.mask[_i]:
					for mask in book_description.mask[_i][put]:
						if !masks.has(mask):
							masks[mask] = []
			
			for mask in masks:
				if mask - 1 < Global.arr.element.size() / 2:
					masks[mask].append_array(Global.arr.primordial)
				else:
					masks[mask].append_array(Global.arr.lateral)
				
				masks[mask].sort_custom(func(a, b): return prioritizeds[a] > prioritizeds[b])
			
			for _i in range(masks.keys().size() - 1, -1, -1):
				var mask = masks.keys()[_i]
				var element = masks[mask].pop_front()
				
				for _j in _i:
					var _mask = masks.keys()[_j]
					
					if masks[_mask].has(element):
						masks[_mask].erase(element)
				
				masks[mask] = element
			
			for _i in Global.dict.book.index[index].scroll:
				var resource = ScrollResource.new()
				resource.index = book_description.scroll[_i]
				var description = Global.dict.scroll.index[resource.index]
				resource.level = description.level
				resource.subtype = description.type
				resource.rarity = "common"
				resource.type = "scroll"
				resource.kind = minion.summary.kind
				
				for put in book_description.mask[_i]:
					resource.masks[put] = {}
					var mask_indexs = book_description.mask[_i][put]
					
					for mask_index in mask_indexs:
						resource.masks[put][mask_index] = masks[mask_index]
				
				var item = nexus.generate_item(resource)
				add_item(item)
	
	minion.grimoire.find_best_items()
	await get_tree().process_frame
	resort_items()
	
func add_item(item_: Item) -> void:
	add_child(item_)
	var slot = free_slots.pop_back()
	occupied_slots.append(slot)
	slot.item = item_
	item_.description.calc_avg()
	minion.grimoire.resources[item_.resource] = item_
	
func resort_items() -> void:
	for slot in occupied_slots:
		slot.item.move_to_initial_position(0)
	
func recalc_avgs() -> void:
	for slot in occupied_slots:
		slot.item.description.calc_avg()
