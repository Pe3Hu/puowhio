class_name Grimoire extends PanelContainer


@export var minion: Minion
@export var scrolls: PanelContainer

@onready var slots = %Slots

var ordered_scrolls: Array[Scroll]
var lists: Array[ListResource]
var books: Array[BookResource]
var incompletes: Array[BookResource]
var occupied_slots: Array[Slot]
var best_book: BookResource
var resources: Dictionary


func _ready():
	for slot in %Slots.get_children():
		slot.refresh_background()
	
func find_best_items() -> void:
	update_scrolls()
	calc_books()
	place_best_book()
	
func update_scrolls() -> void:
	for scroll in minion.library.scrolls.get_children():
		scroll.description.calc_avg()
	
func suit_up(slot_: Slot, item_: Item) -> void:
	if slot_.item != null:
		pass
	
	slot_.item = item_
	item_.move_to_initial_position(0)
	item_.is_description_visible = true
	item_.is_description_locked = true
	ordered_scrolls.push_front(item_)
	minion.library.unsloted_scrolls.erase(item_)
	
func recalc_avgs() -> void:
	for scroll in ordered_scrolls:
		scroll.description.calc_avg()
	
func calc_books() -> void:
	for resource in resources:
		var equilibrium = resource.equilibrium
		var list = null
		
		for list_ in lists:
			if list_.equilibrium.is_equal(equilibrium):
				list = list_
				break
		
		if list == null:
			list = ListResource.new()
			list.equilibrium = equilibrium
			lists.append(list)
		
		list.analogs.append(resource)
	
	incompletes.clear()
	
	for list in lists:
		list.calc_avg()
		
		if list.equilibrium.inputs.is_empty():
			var book = BookResource.new()
			book.lists.append(list)
			book.calc_cycle()
			books.append(book)
			
			if book.is_incomplete(self):
				incompletes.append(book)
	
	var counter = 0
	
	while !incompletes.is_empty() and counter < 5:
		counter += 1
		var originals = []
		originals.append_array(incompletes)
		incompletes.clear()
		
		for original in originals:
			for list in original.reissues:
				var reissue = BookResource.new()
				reissue.lists.append_array(original.lists)
				reissue.lists.append(list)
				reissue.calc_cycle()
				books.append(reissue)
				
				if reissue.is_incomplete(self):
					incompletes.append(reissue)
	
	var bests = []
	books.sort_custom(func(a, b): return a.cycle_avg > b.cycle_avg)
	
	for book in books:
		if book.cycle_avg < books[0].cycle_avg:
			break
		else:
			bests.append(book)
	
	best_book = bests.pick_random()
	
	for best in bests:
		if best.lists.size() > best.lists_cycle.size():
			var list_equilibriums = []
			
			for list in best.lists:
				list_equilibriums.append(list.equilibrium)
	
func place_best_book() -> void:
	erase_slots()
	var index = 0
	
	for list in best_book.lists:
		var scroll = resources[list.get_best_scroll_resource()]
		var slot = %Slots.get_child(index)
		suit_up(slot, scroll)
		index += 1
	
	minion.offensive.resource.value = best_book.cycle_avg
	
func erase_slots() -> void:
	pass
