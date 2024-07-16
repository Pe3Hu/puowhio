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
var expansion_chance = 100.0
var decay_factor = 1#.995
var deque = []
var visited = []
var boundary = []
var frontiers: Dictionary

func add_fiefdom(fiefdom_: Fiefdom) -> void:
	if fiefdom_.get(layer) != null:
		fiefdom_.get(layer).fiefdoms.erase(fiefdom_)
	
	if !fiefdoms.has(fiefdom_):
		fiefdoms.append(fiefdom_)
		fiefdom_.set(layer, self)
	
	if !visited.has(fiefdom_):
		deque.append(fiefdom_)
		visited.append(fiefdom_)
	
	if fiefdom_.domains.size() > 1:
		pass
	while !fiefdom_.domains.is_empty():
		var domain = fiefdom_.domains.pop_back()
		domain.deque.erase(fiefdom_)
	
func recolor_fiefdoms() -> void:
	for fiefdom in fiefdoms:
		fiefdom.color = color
		
		if boundary.has(fiefdom):
			fiefdom.color.v = 0.5
	
func apply_lazy_flood_fill() -> void:
	if fill_end:
		return
	if deque.is_empty():
		fill_end = true
		return
	
	var fiefdom = deque.pop_front()
	add_fiefdom(fiefdom)
	
	if fiefdom.get(layer) != null:
		pass
	
	Global.rng.randomize()
	var random = Global.rng.randi_range(0, 100)
	
	if random <= expansion_chance:
		for neighbor in fiefdom.neighbors:
			#print(neighbor.get(layer))
			if neighbor.get(layer) == null:
				if !visited.has(neighbor) and !deque.has(neighbor):
					deque.append(neighbor)
					neighbor.domains.append(self)
			else:
				pass
		
		expansion_chance *= decay_factor
	
	fill_end = deque.is_empty()
	#print([expansion_chance, random, deque.size(), fill_end])
	
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
	var options = fiefdoms.filter(func(fiefdom): return !boundary.has(fiefdom))
	print([options.size(), fiefdoms.size() - boundary.size()])
