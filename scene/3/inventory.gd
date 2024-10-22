class_name Inventory extends PanelContainer


@export var minion: Minion

var free_slots: Array[Slot]
var occupied_slots: Array[Slot]


func _ready() -> void:
	for slot in %Slots.get_children():
		free_slots.push_front(slot)
	
	#print(minion.statistic.resource.strength_modifier_resources.size())
	
func roll_starter_items() -> void:
	if false:
		return
	var nexus = minion.god.heaven.world.nexus
	var resource = ItemResource.new()
	resource.type = "totem"
	resource.rarity = "uncommon"
	resource.level = 1
	var item = nexus.generate_item(resource)
	add_item(item)
	
	for _i in 8:
		resource = TrigramResource.new()
		resource.rarity = "uncommon"
		resource.level = 1
		resource.type = "trigram"
		resource.subtype = str(_i)
		item = nexus.generate_item(resource)
		add_item(item)
	
	await get_tree().process_frame
	resort_items()
	minion.bagua.find_best_items()
	
func add_item(item_: Item) -> void:
	add_child(item_)
	var slot = free_slots.pop_back()
	occupied_slots.append(slot)
	slot.item = item_
	
func resort_items() -> void:
	for slot in occupied_slots:
		slot.item.move_to_initial_position(0)
