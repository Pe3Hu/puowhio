class_name Grimoire extends PanelContainer


@export var mage: Mage

var ordered_scrolls: Array[Scroll]


func _ready():
	for slot in %Slots.get_children():
		slot.refresh_background()
	
func find_best_items() -> void:
	#var subtypes = ["generator", "absorber"]
	var subtypes = {}
	subtypes["absorber"] =  %Slots.get_child(0)
	subtypes["generator"] =  %Slots.get_child(1)
	
	for subtype in subtypes:
		var items = find_best_scroll(subtype)
		
		if !items.is_empty():
			suit_up(subtypes[subtype], items.front())
	
func find_best_scroll(subtype_: String) -> Array[Item]:
	var options: Array[Item]
	
	for slot in mage.library.occupied_slots:
		var flag = false
		
		if slot.item.resource.subtype == subtype_:
			flag = true
		
		if flag:
			options.append(slot.item)
	
	options.sort_custom(func(a, b): return a.resource.avg < b.resource.avg)
	return options
	
func update_scrolls() -> void:
	for scroll in %Scrolls.get_children():
		scroll.calc_avg()
	
func suit_up(slot_: Slot, item_: Item) -> void:
	if slot_.item != null:
		pass
	
	slot_.item = item_
	item_.move_to_initial_position(0)
	item_.is_description_visible = true
	item_.is_description_locked = true
	ordered_scrolls.push_back(item_)
