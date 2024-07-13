class_name Bagua extends PanelContainer


@export var mage: Mage


func find_best_items() -> void:
	for slot in %Slots.get_children():
		slot.refresh_background()
		var items = find_best_item(slot)
		
		if !items.is_empty():
			suit_up(slot, items.front())
	
func find_best_item(slot_: Slot) -> Array[Item]:
	var options: Array[Item]
	
	for slot in mage.inventory.occupied_slots:
		var flag = false
		
		if slot.item.resource.type == slot_.type:
			if slot_.type == "trigram":
				if slot.item.resource.subtype == slot_.subtype:
					flag = true
			else:
				flag = true
		
		if flag:
			options.append(slot.item)
	
	return options
	
func suit_up(slot_: Slot, item_: Item) -> void:
	if slot_.item != null:
		for resource in item_.resource.bases:
			var resources = mage.statistic.get(resource.aspect + "_resources")
			resources.erase(resource)
			var doublet = mage.statistic.get(resource.aspect)
			doublet.value -= resource.value
	
	slot_.item = item_
	item_.move_to_initial_position(0)
	
	for resource in item_.resource.bases:
		var resources = mage.statistic.get(resource.aspect + "_resources")
		resources.append(resource)
		var doublet = mage.statistic.get(resource.aspect)
		doublet.value += resource.value

