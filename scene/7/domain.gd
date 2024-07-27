class_name Domain extends Node2D


@export_enum("earldom", "barony", "dukedom", "kingdom", "empire") var layer: = "earldom":
	set(layer_):
		layer = layer_
		
		index = int(Global.num.index[layer])
		Global.num.index[layer] += 1
		var hue = index / float(map.get(layer + "_count"))
		color = Color.from_hsv(hue, 0.7, 0.9)
		var domains = map.get(layer + "s")
		domains.append(self)
	get:
		return layer

@export var map: Map:
	set(map_):
		map = map_
		
	get:
		return map
@export var perimeter: Perimeter

@export var index: int
@export var color: Color

@export var fiefdoms: Array[Fiefdom]
@export var vassals: Array[Domain]
@export var senor: Domain
@export var deadends: Array[Deadend]

var fill_end = false
var grid = Vector2()
var ring = float()


func add_vassal(domain_: Domain) -> void:
	for fiefdom in domain_.fiefdoms:
		add_fiefdom(fiefdom)
	
	vassals.append(domain_)
	domain_.senor = self
	map.wave.erase(domain_)
	
func add_fiefdom(fiefdom_: Fiefdom) -> void:
	ring *= fiefdoms.size()
	grid *= fiefdoms.size()
	fiefdom_.set(layer, self)
	
	if !fiefdoms.has(fiefdom_):
		fiefdoms.append(fiefdom_)
		ring += float(fiefdom_.resource.ring)
		grid += Vector2(fiefdom_.resource.grid)
	
	ring /= fiefdoms.size()
	grid /= fiefdoms.size()
	perimeter.set_fiefdom_as_external(fiefdom_)
	
func apply_flood_fill() -> void:
	var vassal_layer = Global.dict.vassal[layer]
	
	while !fill_end:
		if perimeter.proximates.is_empty():
			fill_end = true
			return
		
		var options = []
		
		for fiefdom in perimeter.proximates:#.duplicate():
			var vassal = fiefdom.get(vassal_layer)
			
			if !options.has(vassal) and vassal.senor == null:
				options.append(vassal)
		
		if options.is_empty():
			fill_end = true
			return
		else:
			var weights = {}
			
			for vassal in options:
				var neighbors = vassal.perimeter.proximates.filter(func (a): return perimeter.externals.has(a))
				weights[vassal] = neighbors.size()
		
			options = weights.keys()
			options.sort_custom(func(a, b): return weights[a] > weights[b])
			var near_deadends = []
			
			if !map.roots.is_empty():
				var roots = options.filter(func (a): return map.roots.has(a))
				
				if !roots.is_empty():
					
					for root in roots:
						for deadend in root.deadends:
							if !near_deadends.has(deadend):
								near_deadends.append(deadend)
			
			if near_deadends.is_empty():
				var index = map.corners.find(map.corner)
				var anchor = map.anchors[index]
				options.sort_custom(func(a, b): return abs(a.grid.x + anchor.x) + abs(a.grid.y + anchor.y) < abs(b.grid.x + anchor.x) + abs(b.grid.y + anchor.y))
				options = options.filter(func(a): return abs(a.grid.x + anchor.x) + abs(a.grid.y + anchor.y) == abs(options[0].grid.x + anchor.x) + abs(options[0].grid.y + anchor.y))
				var vassal = options.pick_random()
				add_vassal(vassal)
			else:
				near_deadends.sort_custom(func(a, b): return (a.grid.x + a.grid.y) < (b.grid.x + b.grid.y))
				near_deadends = near_deadends.filter(func (a): return (a.grid.x + a.grid.y) == (near_deadends[0].grid.x + near_deadends[0].grid.y))
				var deadend = near_deadends.pick_random()
				absorb_deadend(deadend)
			
			if map.get(layer + "_vassals") == vassals.size():
				fill_end = true
			
			var new_wave = perimeter.proximates.filter(func(a): return !map.wave.has(a.get(vassal_layer)))
			
			for fiefdom in new_wave:
				var domain = fiefdom.get(vassal_layer)
				
				if domain.senor == null:
					if !map.wave.has(domain):
						map.wave.append(domain)
			
			map.update_wave(layer)
			map.find_deadends(layer)
	
func absorb_deadend(deadend_: Deadend) -> void:
	while map.get(layer + "_vassals") > vassals.size() and deadend_.chain.size() > 0:
		var vassal = deadend_.root
		deadend_.remove_domain(vassal)
		add_vassal(vassal)
	
	if map.get(layer + "_vassals") == vassals.size():
		fill_end = true
	
	if deadend_.chain.size() == 1:
		deadend_.crush()
	
func absorb_domain(domain_: Domain) -> void:
	for fiefdom in domain_.fiefdoms:
		domain_.remove_fiefdom(fiefdom)
		add_fiefdom(fiefdom)
	
	domain_.crush()
	connect_all_fiefdoms()
	#vassal and senor adds
	
func remove_fiefdom(fiefdom_: Fiefdom) -> void:
	fiefdom_.set(layer, null)
	fiefdoms.erase(fiefdom_)
	
func connect_all_fiefdoms() -> void:
	for fiefdom in fiefdoms:
		for direction in fiefdom.direction_fiefdoms:
			if !fiefdom.direction_trails.has(direction):
				var neighbor = fiefdom.direction_fiefdoms[direction]
				
				if neighbor.get(layer) == self or neighbor.get(layer) == null:
					var parity = Global.dict.direction.windrose.find(direction) % 2
					
					if parity == 0:
						map.add_trail(direction, fiefdom, neighbor)
	
func recolor_fiefdoms() -> void:
	for fiefdom in fiefdoms:
		fiefdom.color = color
		#var k = 12
		#
		#if index % k != 0:
			#fiefdom.color.h += 1.0 / k * (index % k)
			#
			#if fiefdom.color.h > 1:
				#fiefdom.color.h -= 1
		
		#if fiefdoms.size() != 6:
		#	fiefdom.color = Color.DIM_GRAY
		
		#if boundary.has(fiefdom):
		#	fiefdom.color.v = 0.5
	
func crush() -> void:
	Global.num.index[layer] -= 1
	var domains = map.get(layer + "s")
	
	#vassal and senor removes
	
	domains.erase(self)
	queue_free()
	
func init_from_indexs(indexs_: Array) -> void:
	for index in indexs_:
		var grid = map.get_grid_from_index(index)
		var fiefdom = map.grids[grid]
		add_fiefdom(fiefdom)
