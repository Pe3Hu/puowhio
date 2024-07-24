class_name Map extends Node2D


@export var earldoms: Array[Domain]
@export var dukedoms: Array[Domain]
@export var kingdoms: Array[Domain]
@export var empires: Array[Domain]
@export var biomes: Array[Biome]
@export var sectors: Array[Sector]
@export var grids: Dictionary
@export var rings: Dictionary

@onready var fiefdom_scene = preload("res://scene/6/fiefdom.tscn")
@onready var trail_scene = preload("res://scene/6/trail.tscn")
@onready var domain_scene = preload("res://scene/7/domain.tscn")
@onready var deadend_scene = preload("res://scene/7/deadend.tscn")
@onready var frontier_scene = preload("res://scene/7/frontier.tscn")
@onready var sector_scene = preload("res://scene/9/sector.tscn")
@onready var biome_scene = preload("res://scene/9/biome.tscn")
@onready var region_scene = preload("res://scene/9/region.tscn")
@onready var fiefdoms = %Fiefdoms
@onready var trails = %Trails
@onready var deadends = %Deadends

#const earldom_l = 40
const earldom_size = Vector2i(40, 40)
const r = 9
const n = 19
const k = 361

const empire_count = 3
const kingdom_count = 12
const dukedom_count = 60
const earldom_count = 360

const empire_vassals = 4
const kingdom_vassals = 5
const dukedom_vassals = 6

const empire_fiefdoms = 120
const kingdom_fiefdoms = 30
const dukedom_fiefdoms = 6

var wave: Array
var frontiers: Dictionary
var roots = {}
var corners = []
var corner = null
var anchors = [
	Vector2(0, 0),
	Vector2(-n-1, 0),
	Vector2(-n-1, -n-1),
	Vector2(0, -n-1),
]
var is_restart = false
var layer = null


func _ready() -> void:
	init_fiefdoms()
	prepare()
	
func prepare() -> void:
	if false:
		return
	
	is_restart = false
	
	init_trails()
	#init_earldoms()
	#init_domains("dukedom")
	init_sectors()
	init_biomes()
	
	#if !is_restart:
		#init_domains("kingdom")
	#if !is_restart:
		#init_domains("empire")
	#for layer in Global.arr.titulus:
		#if layer != "earldom" and layer != "empire":
			#if !is_restart:
				#init_domains(layer)
	
	if is_restart:
		print("restarted")
		reset()
		prepare()
	else:
		pass
	
func reset() -> void:
	frontiers = {}
	roots = {}
	corners = []
	
	while deadends.get_child_count() > 0:
		var deadend = deadends.get_child(0)
		deadend.crush()
		
	while trails.get_child_count() > 0:
		var trail = trails.get_child(0)
		trail.crush()
	
	for layer in Global.arr.titulus:
		var domains = get(layer + "s")
		domains.clear()
		#while domains.get_child_count() > 0:
		#	var domain = domains.get_child(0)
		#	domains.crush()
	
	for fiefdom in fiefdoms.get_children():
		fiefdom.reset()
	
func init_fiefdoms() -> void:
	for ring in r + 1:
		rings[ring] = []
	
	for _i in n:
		for _j in n:
			var fiefdom = fiefdom_scene.instantiate()
			fiefdom.resource.grid = Vector2i(_j, _i)
			fiefdom.map = self
			fiefdoms.add_child(fiefdom)
	
func roll_layer_lazy_flood_fill(layer_: String) -> void:
	for fiefdom in fiefdoms.get_children():
		fiefdom.domains.clear()
	
	var is_ended = false
	var order = []
	
	while !is_ended:
		if order.is_empty():
			var domians = get(layer_+"s")
			domians = domians.filter(func(domian): return !domian.fill_end)
			order.append_array(domians)
			
			if order.is_empty():
				is_ended = false
				break
			else:
				order.shuffle()
		
		if !is_ended:
			while !order.is_empty():
				var domian = order.pop_back()
				Global.rng.randomize()
				domian.apply_lazy_flood_fill()
		
	for domain in empires:
		domain.init_frontier()
	
	var donors = []
	var consumers = []
	var limit = get(layer_ + "_fiefdoms")
	
	for domain in empires:
		if domain.fiefdoms.size() > limit:
			donors.append(domain)
		
		if domain.fiefdoms.size() < limit:
			consumers.append(domain)
	var counter = 1000
	
	while !consumers.is_empty() and counter > 0:
		counter -= 1
		consumers.shuffle()
		var consumer = consumers.pop_back()
		donors.shuffle()
		var donor = donors.pop_back()
		
		consumer.move_frontier(donor)
		
		if donor.fiefdoms.size() > limit:
			donors.append(donor)
		
		if consumer.fiefdoms.size() < limit:
			consumers.append(consumer)
	
func init_trails() -> void:
	for fiefdom in fiefdoms.get_children():
		if !fiefdom.resource.is_locked:
			for direction in Global.dict.direction.windrose:
				var grid = fiefdom.resource.grid + direction
				
				if grids.has(grid):
					var neighbor_fiefdom = grids[grid]
					#fiefdom[direction] = neighbor_fiefdom
					
					if !fiefdom.neighbors.has(neighbor_fiefdom) and !neighbor_fiefdom.resource.is_locked:
						add_trail(direction, fiefdom, neighbor_fiefdom)
						pass
	
	clear_intersecting_trails()
	clear_redundant_trails()
	#clear_border_trails()
	
func add_trail(direction_: Vector2i, a_: Fiefdom, b_: Fiefdom) -> void:
	var trail = trail_scene.instantiate()
	trail.map = self
	trail.direction = direction_
	trails.add_child(trail)
	var pair: Array[Fiefdom]
	pair.append(a_)
	pair.append(b_)
	trail.fiefdoms = pair
	
func clear_border_trails() -> void:
	var directions = Global.dict.direction.linear2.duplicate()
	var direction = directions.pop_front()
	directions.append(direction)
	direction = directions.pop_front()
	
	var first_fiefdom = grids[Vector2i.ZERO]
	var second_fiefdom = null
	
	while second_fiefdom != grids[Vector2i.ZERO]:
		if !first_fiefdom.directions.has(direction):
			if directions.is_empty():
				return
			else:
				direction = directions.pop_front()
		
		var trail = first_fiefdom.directions[direction]
		second_fiefdom = first_fiefdom.trails[trail]
		
		if first_fiefdom.trails.size() > Global.num.trail.min and second_fiefdom.trails.size() > Global.num.trail.min:
			Global.rng.randomize()
			var random = Global.rng.randi_range(0, 1)
			
			if random > 0.0:
				trail.crush()
			
		first_fiefdom = second_fiefdom
	
func clear_intersecting_trails() -> void:
	var e = int(n - 2)
	var exceptions = []
	exceptions.append(Vector2i(0, 0))
	exceptions.append(Vector2i(e, 0))
	exceptions.append(Vector2i(e, e))
	exceptions.append(Vector2i(0, e))
	var directions = []
	directions.append(Vector2i(1, -1))
	directions.append(Vector2i(1, 1))
	directions.append(Vector2i(1, -1))
	directions.append(Vector2i(1, 1))
	var offsets = []
	offsets.append(Vector2i(0, 1))
	offsets.append(Vector2i(0, 0))
	offsets.append(Vector2i(0, 1))
	offsets.append(Vector2i(0, 0))
	
	for _i in n - 1:
		for _j in n - 1:
			var grid = Vector2i(_j, _i)
			
			if !exceptions.has(grid):
				var options = []
				var fiefdom = grids[grid]
				var direction = Vector2i(1, 1)
				
				if fiefdom.direction_trails.has(direction):
					var trail = fiefdom.direction_trails[direction]
					options.append(trail)
					
					grid.x += 1
					fiefdom = grids[grid]
				
				direction = Vector2i(-1, 1)
				
				if fiefdom.direction_trails.has(direction):
					var trail = fiefdom.direction_trails[direction]
					options.append(trail)
				
				if !options.is_empty():
					var option = options.pick_random()
					option.crush()
	
	for _i in exceptions.size():
		var grid = exceptions[_i] + offsets[_i]
		var fiefdom = grids[grid]
		var direction = directions[_i]
		var trail = fiefdom.direction_trails[direction]
		trail.crush()
	
func clear_redundant_trails() -> void:
	var redundants = {}
	var exceptions = []
	var problems = []
	var maximum = 0
	
	for fiefdom in fiefdoms.get_children():
		var m = fiefdom.trails.keys().size()
		
		if m > Global.num.trail.min:
			if !redundants.has(m):
				redundants[m] = []
				
				if maximum < m:
					maximum = int(m)
			
			redundants[m].append(fiefdom)
		else:
			exceptions.append(fiefdom)
	
	#reduce trails each fiefdom of which exceeds the maximum number of trails
	while maximum > Global.num.trail.max:
		if redundants[maximum].is_empty():
			redundants.erase(maximum)
			maximum -= 1
		else:
			var fiefdom = redundants[maximum].pick_random()
			var options = []
			
			for trail in fiefdom.trails:
				if !exceptions.has(fiefdom.trails[trail]):
					options.append(trail)
			
			if !options.is_empty():
				var trail = options.pick_random()
				var flag = true
				
				for _fiefdom in trail.fiefdoms:
					if exceptions.has(_fiefdom):
						flag = false
			
				if flag:
					var keys = redundants.keys()
					keys.sort()
					
					for _fiefdom in trail.fiefdoms:
						for _i in keys:
							if redundants[_i].has(_fiefdom):
								redundants[_i].erase(_fiefdom)
								var _j = _i - 1
								
								if _j > Global.num.trail.min:
									redundants[_j].append(_fiefdom)
								else:
									exceptions.append(_fiefdom)
					
					trail.crush()
			else:
				redundants[maximum].erase(fiefdom)
				problems.append(fiefdom)
	
	#for fiefdom in fiefdoms.get_children():
		#var n = fiefdom.trails.keys().size() - Global.num.trail.min
		#var hue = float(n) / 6
		#fiefdom.color = Color.from_hsv(hue, 0.9, 0.9)
		#
		#if n == -1:
			#fiefdom.color = Color.BLACK
	
func trim_trails(layer_: String) -> void:
	var domains = get(layer_ + "s")
	
	for domain in domains:
		for fiefdom in domain.fiefdoms:
			for _i in range(fiefdom.trails.keys().size() -1, -1, -1):
				var trail = fiefdom.trails.keys()[_i]
				var neighbor = fiefdom.trails[trail]
				
				if neighbor.get(layer_) != domain:
					trail.crush()
			
			while fiefdom.trails.keys().size() > Global.num.trail.worst:
				var trail = fiefdom.trails.keys().pick_random()
				trail.crush()
	
	init_frontiers(layer_)
	
func init_frontiers(layer_) -> void:
	frontiers[layer_] = {}
	var domains = get(layer_ + "s")
	
	for domain in domains:
		var neighbors = {}
		
		for fiefdom in domain.perimeter.proximates:
			var neighbor = fiefdom.get(layer_)
			
			if !neighbors.has(neighbor):
				neighbors[neighbor] = []
			
			neighbors[neighbor].append(fiefdom)
		
		for neighbor in neighbors:
			#var neighbor = neighbors.keys().pick_random()
			var frontier = frontier_scene.instantiate()
			frontier.layer = layer_
			frontier.domains = [domain, neighbor]
			frontier.map = self
	
	if layer_ == "dukedom":
		for fiefdom in fiefdoms.get_children():
			if fiefdom.trails.keys().size() == 1:
				var weights = {}
				
				for direction in fiefdom.direction_fiefdoms:
					var neighbor = fiefdom.direction_fiefdoms[direction]
					weights[neighbor] = neighbor.trails.keys().size()
				
				var options = weights.keys()
				options.sort_custom(func(a, b): return weights[a] < weights[b])
				options = options.filter(func (a): return weights[a] == weights[options[0]])
				options.shuffle()
				var flag = true
				
				while flag:
					flag = false
					
					if options.is_empty():
						return
					
					var neighbor = options.pop_front()
					
					if fiefdom.get(layer_) != neighbor.get(layer_):
						if !fiefdom.get(layer_).perimeter.neighbors.has(neighbor.get(layer_)):
							flag = true
						else:
							var frontier = fiefdom.get(layer_).perimeter.neighbors[neighbor.get(layer_)]
							frontier.add_trail(fiefdom, neighbor)
					else:
						var direction = fiefdom.resource.grid - neighbor.resource.grid
						add_trail(direction, fiefdom, neighbor)
	
func init_earldoms() -> void:
	for fiefdom in fiefdoms.get_children():
		if !fiefdom.resource.is_locked:
			var domain = domain_scene.instantiate()
			domain.map = self
			domain.layer = "earldom"
			earldoms.append(domain)
			domain.add_fiefdom(fiefdom)
	
func init_domains(layer_) -> void:
	corners.clear()
	wave.clear()
	var domains = get(layer_ + "s")
	var vassal_layer = Global.dict.vassal[layer_]
	
	for direction in Global.dict.direction.zero:
		var grid = Vector2i(direction) * (n - 1)
		var fiefdom = grids[grid]
		var _corner = fiefdom.get(vassal_layer)
		corners.append(_corner)
		wave.append(_corner)
	
	var stopper = get(layer_ + "_count")
	var _i = 0
	
	while _i < stopper:
		_i += 1
		
		if wave.is_empty():
			stopper = 0
			is_restart = true
			return
		else:
			add_domain(layer_)
			var domain = domains[domains.size()- 1]
			
			if domain.vassals.size() != get(layer_ + "_vassals"):
				is_restart = true
				stopper = 0
				return
	
	for domain in domains:
		if domain.vassals.size() != get(layer_ + "_vassals"):
			is_restart = true
			return
	
	if !is_restart:
		print("correct ", layer_)
		
		if layer_ == "dukedom":
			trim_trails(layer_)
		
		for domain in domains:
			for fiefdom in domain.fiefdoms:
				fiefdom.set(layer_, domain)
	
func update_wave(layer_: String) -> void:
	for _i in range(wave.size() - 1, -1 -1):
		var domain = wave[_i]
		
		if domain.get(layer_) != null:
			wave.erase(domain)
	
func find_deadends(layer_: String) -> void:
	for domain in wave: 
		var count = 0
		
		for fiefdom in domain.perimeter.proximates:
			if fiefdom.get(layer_) == null:
				count += 1
		
		if count == 1:
			if !roots.has(domain):
				var deadend = deadend_scene.instantiate()
				deadend.map = self
				deadend.layer = layer_
				deadend.root = domain
				deadends.add_child(deadend)
		
	extend_deadends(layer_)
	merge_deadends(layer_)
	update_wave(layer_)
	
func merge_deadends(layer_: String) -> void:
	for _i in range(deadends.get_child_count() - 1, -1 -1):
		var deadend = deadends.get_child(_i)
		var options = deadend.branches.filter(func(a): return a.deadends.is_empty())
		
		if options.is_empty():
			options = deadend.branches.filter(func(a): return !a.deadends.is_empty())
			
			if !options.is_empyt():
				var option = options.pick_random()
				deadend.merge(option)
			else:
				pass
		else:
			deadend.pick_branch()
	
func extend_deadends(layer_: String) -> void:
	var is_connected = true
	
	for deadend in deadends.get_children():
		var options = deadend.branches.filter(func(a): return a.deadends.is_empty())
		
		if options.size() == 1:
			is_connected = false
			deadend.set("is_connected", false)
			deadend.fill_chain()
		
	if !is_connected:
		find_deadends(layer_)
	
func establish_domain(deadend_: Deadend) -> void:
	var domains = get(deadend_.layer + "s")
	var domain = domain_scene.instantiate()
	domain.map = self
	domain.layer = deadend_.layer
	domains.append(domain)
	
	domain.absorb_deadend(deadend_)
	domain.apply_flood_fill()
	
func add_domain(layer_: String) -> void:
	var domains = get(layer_ + "s")
	corner = corners.pick_random()
	var index = corners.find(corner)
	var anchor = anchors[index]
	
	if true:
		if deadends.get_child_count() == 0:
			var domain = domain_scene.instantiate()
			domain.map = self
			domain.layer = layer_
			domains.append(domain)
			wave.sort_custom(func(a, b): return abs(a.grid.x + anchor.x) + abs(a.grid.y + anchor.y) < abs(b.grid.x + anchor.x) + abs(b.grid.y + anchor.y))
			var options = wave.duplicate().filter(func(a): return abs(a.grid.x + anchor.x) + abs(a.grid.y + anchor.y) == abs(wave[0].grid.x + anchor.x) + abs(wave[0].grid.y + anchor.y))
			var vassal = options.pick_random()
			domain.add_vassal(vassal)
			domain.apply_flood_fill()
		else:
			var deadend = deadends.get_children().pick_random()
			establish_domain(deadend)
	
	for domain in domains:
		domain.recolor_fiefdoms()
	
func init_sectors() -> void:
	if !is_restart:
		var _n = 5
		var _k = _n / 2
		var offsets = [0, 4, 8, 11, 15]
		var sizes = [4, 3]
		var grid = Vector2i()
		
		for _i in _n:
			for _j in _n:
				var sector = sector_scene.instantiate()
				sector.grid = Vector2i(offsets[_j], offsets[_i])
				sector.dimensions = Vector2i.ONE * sizes[0]
				
				if _i != _k or _j != _k:
					if _i == _k:
						sector.dimensions.y = sizes[1]
					if _j == _k:
						sector.dimensions.x = sizes[1]
				else:
					sector.dimensions = Vector2i.ZERO
				
				sector.map = self
				sectors.append(sector)
		
		var center = Vector2i.ONE * r
		var shifts = [0, -1]
		shifts.shuffle()
		
		for _i in Global.dict.direction.linear2.size():
			var linear_direction = Global.dict.direction.linear2[_i]
			var _j = (_i + shifts[0] + Global.dict.direction.linear2.size()) % Global.dict.direction.linear2.size()
			var diagonal_direction = Global.dict.direction.diagonal[_j]
			var directions = [linear_direction, diagonal_direction]
			var fiefdoms = []
			
			for direction in directions:
				grid = direction + center
				fiefdoms.append(grids[grid])
			
			var neighbor = fiefdoms[0].direction_fiefdoms[linear_direction]
			
			if !neighbor.sectors.is_empty():
				for fiefdom in fiefdoms:
					for sector in neighbor.sectors:
						sector.add_fiefdom(fiefdom)
	
	for sector in sectors:
		sector.push_proximates()
		#sector.recolor_fiefdoms()
	
func init_biomes() -> void:
	var terrains = {} 
	var options = []
	var lengths = [90]
	
	for terrain in Global.arr.terrain:
		var biome = biome_scene.instantiate()
		biome.terrain = terrain
		biome.map = self
		biomes.append(biome)
		
		if terrain != "coast":
			terrains[terrain] = biome
			var indexs = Global.dict.terrain.title[terrain].sector
			
			for index in indexs:
				var sector = sectors[index]
				biome.options.append_array(sector.fiefdoms)
				options.append_array(sector.fiefdoms)
				
				for fiefdom in sector.fiefdoms:
					fiefdom.biomes.append(biome)
	
	for terrain in terrains:
		var biome = terrains[terrain]
		biome.init_region()
		#var fiefdom = terrains[terrain].pick_random()
		#terrains[terrain].erase(fiefdom)
		#options.erase(fiefdom)
		#biome.add_fiefdom(fiefdom)
	
	var length = lengths.pop_front()
	
	for _i in length - 1:
		for terrain in terrains:
			var biome = terrains[terrain]
			biome.region_expansion()
	
	for biome in biomes:
		if biome.terrain != "coast":
			print([biome.terrain, biome.regions[0].externals.size()])
			biome.recolor_fiefdoms()
	
func shift_domain_layer(shift_: int ) -> void:
	var index = (Global.arr.titulus.find(layer) + shift_ + Global.arr.titulus.size()) % Global.arr.titulus.size()
	layer = Global.arr.titulus[index]
	var domains = get(layer + "s")
	
	for domain in domains:
		domain.recolor_fiefdoms()
	
func _input(event) -> void:
	if event is InputEventKey:
		if event.is_pressed() && !event.is_echo():
			match event.keycode:
				KEY_A:
					shift_domain_layer(-1)
				KEY_D:
					shift_domain_layer(1)
	
