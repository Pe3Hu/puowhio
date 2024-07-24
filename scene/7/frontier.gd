class_name Frontier extends Node2D


@export_enum("earldom", "dukedom", "kingdom", "empire") var layer: = "earldom":
	set(layer_):
		layer = layer_
	get:
		return layer

@export var map: Map:
	set(map_):
		map = map_
		
		layer = domains.front().layer
		init_references()
		
		if layer == "dukedom":
			init_trail()
		else:
			select_trails()
	get:
		return map

@export var domains: Array
@export var trails: Array[Trail]


func init_references() -> void:
	var a = domains[0]
	var b = domains[1]
	
	if !map.frontiers[layer].has(a):
		map.frontiers[layer][a] = {}
	
	if !map.frontiers[layer].has(b):
		map.frontiers[layer][b] = {}
	
	map.frontiers[layer][a][b] = self
	map.frontiers[layer][b][a] = self
	a.perimeter.frontiers[self] = b
	b.perimeter.frontiers[self] = a
	a.perimeter.neighbors[b] = self
	b.perimeter.neighbors[a] = self
	
func init_trail() -> void:
	trails.clear()
	
	var a = domains[0]
	var b = domains[1]
	var pairs = {}
	
	for fiefdom_a in a.perimeter.externals:
		for direction in fiefdom_a.direction_fiefdoms:
			var fiefdom_b = fiefdom_a.direction_fiefdoms[direction]
			var parity = Global.dict.direction.windrose.find(direction) % 2
		
			if b.perimeter.externals.has(fiefdom_b) and parity == 0:
				if !pairs.has(fiefdom_a):
					pairs[fiefdom_a] = []
				
				if !pairs.has(fiefdom_b):
					pairs[fiefdom_b] = []
				
				pairs[fiefdom_a].append(fiefdom_b)
				pairs[fiefdom_b].append(fiefdom_a)
	
	if !pairs.keys().is_empty():
		var fiefdoms = pairs.keys()
		fiefdoms.sort_custom(func(a, b): return pairs[a].size() < pairs[b].size())
		fiefdoms = fiefdoms.filter(func (a): return pairs[a].size() == pairs[fiefdoms[0]].size())
		
		var fiefdom_a = fiefdoms.pick_random()
		var fiefdom_b = pairs[fiefdom_a].pick_random()
		add_trail(fiefdom_a, fiefdom_b)
	
func add_trail(a_: Fiefdom, b_: Fiefdom) -> void:
	var direction = a_.resource.grid - b_.resource.grid
	map.add_trail(direction, a_, b_)
	var trail = a_.direction_trails[direction]
	trails.append(trail)
	
func select_trails() -> void:
	pass
