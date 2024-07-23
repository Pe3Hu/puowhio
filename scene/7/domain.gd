class_name Domain extends Node2D


@export_enum("earldom", "barony", "dukedom", "kingdom", "empire") var layer: = "earldom":
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
	
	if !fiefdoms.has(fiefdom_):
		fiefdoms.append(fiefdom_)
		fiefdom_.set(layer, self)
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
				var best_weight = weights[options[0]]
				options = options.filter(func (a): return weights[a] == best_weight)
				#var vassal = Global.get_random_key(weights)
				var vassal = options.pick_random()
				add_vassal(vassal)
				print("V", vassal.fiefdoms[0].resource.grid)
			else:
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
			
			#if map.roots.has(vassal):
				#map.roots[vassal].crush()
	
func absorb_deadend(deadend_: Deadend) -> void:
	while map.get(layer + "_vassals") > vassals.size() and deadend_.chain.size() > 0:
		var vassal = deadend_.root
		deadend_.remove_domain(vassal)
		add_vassal(vassal)
		print("A", vassal.fiefdoms[0].resource.grid)
	
	if map.get(layer + "_vassals") == vassals.size():
		fill_end = true
	
	if deadend_.chain.size() == 1:
		deadend_.crush()
	
func recolor_fiefdoms() -> void:
	for fiefdom in fiefdoms:
		fiefdom.color = color
		var k = 3
		
		if index % k != 0:
			fiefdom.color.h += 1.0 / k * (index % k)
			
			if fiefdom.color.h > 1:
				fiefdom.color.h -= 1
		
		#if fiefdoms.size() != 6:
		#	fiefdom.color = Color.DIM_GRAY
		
		#if boundary.has(fiefdom):
		#	fiefdom.color.v = 0.5
	
