class_name Inventory extends PanelContainer


@export var mage: Mage

var free_slots: Array[Slot]
var occupied_slots: Array[Slot]


func _ready() -> void:
	for slot in %Slots.get_children():
		free_slots.push_front(slot)
	
	roll_starter_items()
	await get_tree().process_frame
	resort_items()
	mage.bagua.find_best_items()
	mage.grimoire.find_best_items()
	#print(mage.statistic.resource.strength_modifier_resources.size())

func roll_starter_items() -> void:
	if false:
		return
	var nexus = mage.battle.world.nexus
	var resource = ItemResource.new()
	resource.type = "nucleus"
	resource.rarity = "common"
	resource.level = 1
	var item = nexus.generate_item(resource)
	add_item(item)
	
	for _i in 8:
		resource = TrigramResource.new()
		resource.rarity = "common"
		resource.level = 1
		resource.type = "trigram"
		resource.subtype = str(_i)
		item = nexus.generate_item(resource)
		add_item(item)
	
	
func add_item(item_: Item) -> void:
	add_child(item_)
	var slot = free_slots.pop_back()
	occupied_slots.append(slot)
	slot.item = item_
	
func resort_items() -> void:
	for slot in occupied_slots:
		slot.item.move_to_initial_position(0)
