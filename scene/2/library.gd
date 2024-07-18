class_name Library extends PanelContainer


@export var minion: Minion

var free_slots: Array[Slot]
var occupied_slots: Array[Slot]


func _ready() -> void:
	for slot in %Slots.get_children():
		free_slots.push_front(slot)
		slot.refresh_background()
	
	roll_starter_items()
	
	await get_tree().process_frame
	resort_items()
	
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
		#"monster":
			#var options = Global.dict.book.level[minion.re]
	
	#minion.grimoire.find_best_items()
	
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
