class_name Domain extends Node2D


@export_enum("earldom", "dukedom", "kingdom", "empire") var layer: = "earldom":
	set(layer_):
		layer = layer_
		
		index = int(Global.num.index[layer])
		Global.num.index[layer] += 1
		var hue = index / float(map.get(layer + "_count"))
		color = Color.from_hsv(hue, 0.7, 0.9)
	get:
		return layer
@export var map: Map:
	set(map_):
		map = map_
		
	get:
		return map
@export var index: int
@export var color: Color

@export var fiefdoms: Array[Fiefdom]
@export var vassal: Array[Domain]
@export var senor: Domain

var fill_end = false
var boundary = []
var frontiers: Dictionary

func add_fiefdom(fiefdom_: Fiefdom) -> void:
	#if fiefdom_.get(layer) != null:
		#fiefdom_.get(layer).fiefdoms.erase(fiefdom_)
	
	if !fiefdoms.has(fiefdom_):
		fiefdoms.append(fiefdom_)
		fiefdom_.set(layer, self)
	
	update_boundary(fiefdom_)
	
func recolor_fiefdoms() -> void:
	for fiefdom in fiefdoms:
		fiefdom.color = color
		
		fiefdom.color.v = (6.0 + index % 6) / 12.0
		
		if fiefdoms.size() != 6:
			fiefdom.color = Color.DIM_GRAY
		
		if boundary.has(fiefdom):
			fiefdom.color.v = 0.5
		
	
func apply_flood_fill(contacts_: Dictionary) -> void:
	while !fill_end:
		if boundary.is_empty():
			fill_end = true
			return
		
		var options = boundary.filter(func (a): return contacts_.fiefdom.has(a))
		var exeptions = options.filter(func (a): return contacts_.fiefdom[a].size() < 2)
		var weights = {}
		
		if exeptions.is_empty():
			for ring in range(contacts_.ring, 0, -1):
				var result = []
				
				for option in options:
					if map.rings[ring].has(option):
						result.append(option)
					
				if !result.is_empty():
					options = result
					break
			
			for fiefdom in options:
				var neighbors = fiefdom.neighbors.keys().filter(func (a): return fiefdoms.has(a))
				weights[fiefdom] = neighbors.size()
		else:
			for exeption in exeptions:
				weights[exeption] = 1
		
		if weights.is_empty():
			fill_end = true
			return
		else:
			var fiefdom = Global.get_random_key(weights)
			add_fiefdom(fiefdom)
			map.cross_out(contacts_, fiefdom)
			
			if map.get(layer + "_vassals") == fiefdoms.size():
				fill_end = true
		
	for fiefdom in boundary:
		if contacts_.fiefdom.has(fiefdom):
			if map.rings[contacts_.ring].has(fiefdom):
				#contacts_.corner.append(fiefdom)
				pass
			#fiefdom.color = Color.BLACK
			
		#fill_end = true
	
func init_frontier() -> void:
	boundary.clear()
	
	for fiefdom in fiefdoms:
		var is_boundary = false
		
		for neighbor_fiefdom in fiefdom.neighbors:
			var neighbor_domain = neighbor_fiefdom.get(layer)
			
			if neighbor_domain != self:
				if !frontiers.has(neighbor_domain):
					frontiers[neighbor_domain] = []
					neighbor_domain.frontiers[self] = []
				
				if !frontiers[neighbor_domain].has(fiefdom):
					frontiers[neighbor_domain].append(fiefdom)
					neighbor_domain.frontiers[self].append(neighbor_fiefdom)
				
				is_boundary = true
		
		if is_boundary:
			boundary.append(fiefdom)
	
func move_frontier(neighbor_: Domain) -> void:
	var options = {}
	var weights = {}
	
	for fiefdom in frontiers[neighbor_]:
		weights[fiefdom] = 0
		options[fiefdom] = []
		
		for neighbor_fiefdom in fiefdom.neighbors:
			var neighbor_domain = neighbor_fiefdom.get(layer)
			
			if neighbor_domain != self:
				weights[fiefdom] += 1
				options[fiefdom].append(neighbor_fiefdom)
	
	if !weights.keys().is_empty():
		var consumer_fiefdom = Global.get_random_key(weights)
		frontiers[neighbor_].erase(consumer_fiefdom)
		var is_boundary = false
		
		for neighbor in frontiers:
			if frontiers[neighbor].has(consumer_fiefdom):
				is_boundary = true
				break
		
		if !is_boundary:
			boundary.erase(consumer_fiefdom)
		
		var donor_fiefdom = options[consumer_fiefdom].pick_random()
		neighbor_.frontiers[self].erase(donor_fiefdom)
		neighbor_.boundary.erase(donor_fiefdom)
		add_fiefdom(donor_fiefdom)
		
		for neighbor_fiefdom in donor_fiefdom.neighbors:
			if !neighbor_.boundary.has(neighbor_fiefdom):
				neighbor_.boundary.append(neighbor_fiefdom)
				
			if !neighbor_.frontiers[self].has(neighbor_fiefdom):
				neighbor_.frontiers[self].append(neighbor_fiefdom)
	
func init_vassals() -> void:
	#var options = fiefdoms.filter(func(fiefdom): return !boundary.has(fiefdom))
	#print([options.size(), fiefdoms.size() - boundary.size()])
	pass
	
func update_boundary(fiefdom_: Fiefdom) -> void:
	boundary.erase(fiefdom_)
	fiefdom_.color = Color.RED
	
	for neighbor in fiefdom_.neighbors:
		if !boundary.has(neighbor) and !fiefdoms.has(neighbor):
			if neighbor.get(layer) == null:
				boundary.append(neighbor)
			#neighbor.color = Color.BLACK
	
func original_apply_flood_fill(contacts_: Dictionary) -> void:
	while !fill_end:
		if fill_end:
			return
		if boundary.is_empty():
			fill_end = true
			return
		
		var options = boundary.filter(func (a): return contacts_.fiefdom.has(a))
		options.sort_custom(func(a, b): return contacts_.fiefdom[a].size() < contacts_.fiefdom[b].size())
		
		for ring in range(contacts_.ring, 0, -1):
			var result = []
			
			for option in options:
				if map.rings[ring].has(option):
					result.append(option)
				
			if !result.is_empty():
				options = result
				break
		
		if options.is_empty():
			fill_end = true
			return
		
		var k = contacts_.fiefdom[options.front()].size()
		options = options.filter(func (a): return contacts_.fiefdom[a].size() == k)
		
		if !options.is_empty():
			var fiefdom = options.pick_random()
			add_fiefdom(fiefdom)
			map.cross_out(contacts_, fiefdom)
			
			fill_end = boundary.is_empty()
			#print([fiefdoms.size(), boundary.size()])
			
			if map.get(layer + "_vassals") == fiefdoms.size():
				fill_end = true
		else:
			pass
		
	for fiefdom in boundary:
		if contacts_.fiefdom.has(fiefdom):
			if map.rings[contacts_.ring].has(fiefdom):
				#contacts_.corner.append(fiefdom)
				pass
			#fiefdom.color = Color.BLACK
			
		#fill_end = true
