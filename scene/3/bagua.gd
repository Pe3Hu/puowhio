class_name Bagua extends PanelContainer


@export var minion: Minion


func find_best_items() -> void:
	for slot in %Slots.get_children():
		slot.refresh_background()
		var items = find_best_item(slot)
		
		if !items.is_empty():
			suit_up(slot, items.front())
	
func find_best_item(slot_: Slot) -> Array[Item]:
	var options: Array[Item]
	
	for slot in minion.inventory.occupied_slots:
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
		slot_.item.is_description_locked = false
		slot_.item.is_description_visible = false
		
		for resource in item_.resource.bases:
			var resources = minion.statistic.resource.get(resource.subtype + "_" + resource.measure +  "_resources")
			resources.erase(resource)
			minion.statistic.update_doublet(resource.subtype + "_modifier")
	
	slot_.item = item_
	slot_.item.is_description_visible = true
	slot_.item.is_description_locked = true
	item_.move_to_initial_position(0)
	
	for resource in item_.resource.bases:
		var title = resource.subtype + "_" + resource.measure +  "_resources"
		var resources = minion.statistic.resource.get(title)
		
		if !resources.has(resource):
			resources.append(resource)
			minion.statistic.update_doublet(resource.subtype + "_modifier")
	
	for resource in item_.resource.affixs:
		var title = resource.subtype + "_" + resource.measure +  "_resources"
		var resources = minion.statistic.resource.get(title)
		
		if !resources.has(resource):
			resources.append(resource)
			minion.statistic.update_doublet(resource.subtype + "_" + resource.measure)
	
	for slot in minion.library.occupied_slots:
		slot.item.description.calc_avg()
	
	for slot in minion.grimoire.ordered_scrolls:
		slot.item.description.calc_avg()

