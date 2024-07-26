class_name Map extends Node2D


@export var world: World

var earldoms: Array[Domain]
var dukedoms: Array[Domain]
var kingdoms: Array[Domain]
var empires: Array[Domain]
var biomes: Array[Biome]
var sectors: Array[Sector]

var grids: Dictionary
var rings: Dictionary

#region scenes
@onready var fiefdom_scene = preload("res://scene/6/fiefdom.tscn")
@onready var trail_scene = preload("res://scene/6/trail.tscn")
@onready var domain_scene = preload("res://scene/7/domain.tscn")
@onready var deadend_scene = preload("res://scene/7/deadend.tscn")
@onready var frontier_scene = preload("res://scene/7/frontier.tscn")
@onready var sector_scene = preload("res://scene/9/sector.tscn")
@onready var biome_scene = preload("res://scene/9/biome.tscn")
@onready var region_scene = preload("res://scene/9/region.tscn")
@onready var god_scene = preload("res://scene/11/god.tscn")
#endregion

@onready var fiefdoms = %Fiefdoms
@onready var trails = %Trails
@onready var deadends = %Deadends

#const earldom_l = 40
#region domain numbers
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
#endregion

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
	#init_trails()
	init_sectors()
	init_biomes()
	
	prepare()
	
func prepare() -> void:
	if false:
		return
	
	is_restart = false
	init_trails()
	clear_intersecting_trails()
	clear_redundant_trails()
	
	init_earldoms()
	init_domains("dukedom")
	
	if !is_restart:
		init_domains("kingdom")
	if !is_restart:
		init_domains("empire")
	
	if !is_restart:
		layer = "empire"
		#shift_domain_layer(0)
		init_gods()
		init_thickets()
	
	#for fiefdom in fiefdoms.get_children():
	#	if fiefdom.resource.is_border:
	#		fiefdom.color = Color.BLACK
	
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
	
	for _layer in Global.arr.titulus:
		var domains = get(_layer + "s")
		domains.clear()
		#while domains.get_child_count() > 0:
		#	var domain = domains.get_child(0)
		#	domains.crush()
	
	for fiefdom in fiefdoms.get_children():
		fiefdom.reset()
	
#region feifdom
func init_fiefdoms() -> void:
	for ring in r + 1:
		rings[ring] = []
	
	for _i in n:
		for _j in n:
			var fiefdom = fiefdom_scene.instantiate()
			fiefdom.resource.grid = Vector2i(_j, _i)
			fiefdom.map = self
			fiefdoms.add_child(fiefdom)
	
	for fiefdom in fiefdoms.get_children():
		if !fiefdom.resource.is_locked:
			for direction in Global.dict.direction.windrose:
				var grid = fiefdom.resource.grid + direction
				
				if grids.has(grid):
					var neighbor = grids[grid]
					
					if !neighbor.resource.is_locked and !fiefdom.direction_fiefdoms.has(direction):
						fiefdom.direction_fiefdoms[direction] = neighbor
	
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
					var neighbor = grids[grid]
					#fiefdom[direction] = neighbor_fiefdom
					
					if !fiefdom.neighbors.has(neighbor) and !neighbor.resource.is_locked:
						add_trail(direction, fiefdom, neighbor)
						pass
	
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
	
	var a = grids[Vector2i.ZERO]
	var b = null
	
	while b != grids[Vector2i.ZERO]:
		if !a.direction_trails.has(direction):
			if directions.is_empty():
				return
			else:
				direction = directions.pop_front()
		
		var trail = a.direction_trails[direction]
		b = a.trails[trail]
		
		if a.trails.size() > Global.num.trail.min and b.trails.size() > Global.num.trail.min:
			Global.rng.randomize()
			var random = Global.rng.randi_range(0, 1)
			
			if random > 0.0:
				trail.crush()
		
		a = b
	
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
	
#endregion
#region domain
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
	var _is_connected = true
	
	for deadend in deadends.get_children():
		var options = deadend.branches.filter(func(a): return a.deadends.is_empty())
		
		if options.size() == 1:
			_is_connected = false
			deadend.set("is_connected", false)
			deadend.fill_chain()
		
	if !_is_connected:
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
#endregion
#region biome
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
			var _fiefdoms = []
			
			for direction in directions:
				grid = direction + center
				_fiefdoms.append(grids[grid])
			
			var neighbor = _fiefdoms[0].direction_fiefdoms[linear_direction]
			
			if !neighbor.sectors.is_empty():
				for fiefdom in _fiefdoms:
					for sector in neighbor.sectors:
						sector.add_fiefdom(fiefdom)
	
	for sector in sectors:
		sector.push_proximates()
		#sector.recolor_fiefdoms()
	
func init_biomes() -> void:
	var terrains = {} 
	var options = []
	
	for terrain in Global.arr.terrain:
		var biome = biome_scene.instantiate()
		biome.terrain = terrain
		
		if terrain != "coast":
			terrains[terrain] = biome
			var indexs = Global.dict.terrain.title[terrain].sector
			
			for index in indexs:
				var sector = sectors[index]
				biome.options.append_array(sector.fiefdoms)
				options.append_array(sector.fiefdoms)
				
				for fiefdom in sector.fiefdoms:
					fiefdom.biomes.append(biome)
		
		biome.map = self
		biomes.append(biome)
	
	for _i in Global.num.biome.n * 2:
		for terrain in terrains:
			var biome = terrains[terrain]
			biome.region_expansion()
	
	for biome in biomes:
		for region in biome.regions:
			region.update_proximates()
	
	biomes_penetrations()
	exchange_between_supplier_and_consumer_biomes()
	exchange_swamp_and_jungle_biomes()
	exchange_coast_biomes()
	mediator_coast_biomes()
		
	exchange_quadrats_biomes()
	
func biomes_penetrations() -> void:
	#tundra mountain volcano desert terrains
	var pairs = [
		[3, 6],
		[3, 4],
		[6, 2]
	]
	
	for pair in pairs:
		biome_penetrations(biomes[pair[0]], biomes[pair[1]], true)
	
	#tundra plain terrains
	pairs = [
		[1, 4],
		[1, 2]
	]
	
	var datas = []
	
	for pair in pairs:
		var data = {}
		data.pair = pair
		data.extensions = biome_penetrations(biomes[pair[0]], biomes[pair[1]], false).size()
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.extensions < b.extensions)
	var _pair = datas.front().pair
	biome_penetrations(biomes[_pair[0]], biomes[_pair[1]], true)
	
	#swamp jungle terrains
	pairs = [
		[0, 7]
	]
	
	for pair in pairs:
		biome_penetrations(biomes[pair[0]], biomes[pair[1]], true)
	
func biome_penetrations(a_: Biome, b_: Biome, is_penetration_: bool) -> Array:
	var _trails = []
	var regions = {}
	regions.a = a_.regions[0]
	regions.b = b_.regions[0]
	var _fiefdoms = {}
	_fiefdoms[regions.a] = []
	_fiefdoms[regions.b] = []
	
	for fiefdom in regions.a.proximates:
		if regions.b.externals.has(fiefdom):
			for direction in fiefdom.direction_fiefdoms:
				var neighbor = fiefdom.direction_fiefdoms[direction]
				
				if regions.a.externals.has(neighbor):
					var parity = Global.dict.direction.windrose.find(direction) % 2
					
					if parity == 0:
						#var trail = fiefdom.direction_trails[direction]
						#_trails.append(trail)
						#trail.default_color = Color.BLACK
						_trails.append(fiefdom)
						
						if !_fiefdoms[regions.a].has(neighbor):
							_fiefdoms[regions.a].append(neighbor)
						if !_fiefdoms[regions.b].has(fiefdom):
							_fiefdoms[regions.b].append(fiefdom)
	
	if is_penetration_:
		for region in _fiefdoms:
			var neighbors = []
			
			for fiefdom in _fiefdoms[region]:
				for direction in fiefdom.direction_fiefdoms:
					var neighbor = fiefdom.direction_fiefdoms[direction]
					
					if region.externals.has(neighbor) and !neighbors.has(neighbor) and !_fiefdoms[region].has(neighbor):
						neighbors.append(neighbor)
			
			_fiefdoms[region].append_array(neighbors)
		
		regions.a.separate(_fiefdoms[regions.a])
		regions.b.separate(_fiefdoms[regions.b])
		b_.attach_region(_fiefdoms[regions.a])
		a_.attach_region(_fiefdoms[regions.b])
	
	return _trails
	
func exchange_between_supplier_and_consumer_biomes() -> void:
	var suppliers = {}
	var consumers = {}
	
	for biome in biomes:
		if biome.terrain != "coast":
			biome.update_fiefdoms()
			
			if Global.num.biome.n > biome.fiefdoms.size():
				consumers[biome] = Global.num.biome.n - biome.fiefdoms.size()
			if Global.num.biome.n < biome.fiefdoms.size():
				suppliers[biome] = biome.fiefdoms.size() - Global.num.biome.n
	
	while !consumers.keys().is_empty():
		var consumer = consumers.keys().pick_random()
		var proximates = []
		var weights = {}
		
		for region in consumer.regions:
			var _proximates = region.proximates.filter(func(a): return !proximates.has(a))
			proximates.append_array(_proximates)
		
		for supplier in suppliers:
			for region in supplier.regions:
				for external in region.externals:
					if proximates.has(external):
						weights[region] = region.externals.size()
						break
		
		if !weights.is_empty():
			var _suppliers = weights.keys()
			_suppliers.filter(func(a): return weights[a] > consumers[consumer])
			_suppliers.sort_custom(func(a, b): return weights[a] > weights[b])
			var supplier = _suppliers[0]
			var count = supplier.replenish_biome(consumer, consumers[consumer])
			suppliers[supplier.biome] -= count
			consumers[consumer] -= count
			
			if consumers[consumer] == 0:
				consumers.erase(consumer)

func exchange_swamp_and_jungle_biomes() -> void:
	var centrals = ["jungle", "swamp"]
	
	for biome in biomes:
		if centrals.has(biome.terrain):
			if Global.num.biome.n < biome.fiefdoms.size():
				var supply = biome.fiefdoms.size() - Global.num.biome.n
				var supplier = biome.regions[0]
				var proximates = supplier.proximates.duplicate()
				var weights = {}
				
				for consumer in biomes:
					if !centrals.has(consumer.terrain) and consumer.terrain != "coast":
						for region in consumer.regions:
							for external in region.externals:
								if proximates.has(external):
									weights[region] = region.externals.size()
									break
				
				var _consumers = weights.keys()
				_consumers.sort_custom(func(a, b): return weights[a] < weights[b])
				var consumer = _consumers[0]
				supplier.replenish_biome(consumer.biome, supply)
	
	for biome in biomes:
		biome.update_fiefdoms()
		
		for region in biome.regions:
			region.update_proximates()

	
func exchange_coast_biomes() -> void:
	var centrals = ["jungle", "swamp"]
	var suppliers = {}
	
	for biome in biomes:
		if biome.terrain != "coast":
			if !centrals.has(biome.terrain):
				if Global.num.biome.n < biome.fiefdoms.size():
					suppliers[biome] = biome.fiefdoms.size() - Global.num.biome.n
					#print(["supplier", biome.terrain, suppliers[biome]])
				
	#coast terrain
	var _biomes = suppliers.keys()
	_biomes.sort_custom(func(a, b): return suppliers[a] < suppliers[b])
	
	for biome in _biomes:
		var _waves = biome.tide(suppliers[biome])
		suppliers[biome] -= _waves
		
		if suppliers[biome] == 0:
			suppliers.erase(biome)
	
	for biome in biomes:
		biome.update_fiefdoms()
		
		for region in biome.regions:
			region.update_proximates()
	
func mediator_coast_biomes() -> void:
	var suppliers = {}
	
	for biome in biomes:
		if biome.terrain != "coast":
			if Global.num.biome.n < biome.fiefdoms.size():
				suppliers[biome] = biome.fiefdoms.size() - Global.num.biome.n
	
	if !suppliers.is_empty():
		for supplier in suppliers:
			var mediators = {}
			var proximates = []
			
			for region in supplier.regions:
				var _proximates = region.proximates.filter(func(a): return !proximates.has(a) and a.biome != supplier and a.biome.terrain != "coast")
				proximates.append_array(_proximates)
			
			for fiefdom in proximates:
				if !mediators.has(fiefdom.region):
					mediators[fiefdom.region] = fiefdom.region.externals.filter(func(a): return a.resource.is_border) 
					
					if mediators[fiefdom.region].is_empty():
						mediators.erase(fiefdom.region)
					else:
						mediators[fiefdom.region].shuffle()
			
			for _i in suppliers[supplier]:
				if !mediators.is_empty():
					var mediator = mediators.keys().pick_random()#Global.get_random_key(mediators)
					var fiefdom = mediators[mediator].pop_front()
					mediator.remove_fiefdom(fiefdom)
					biomes[5].regions[0].add_fiefdom(fiefdom)
					mediator.update_proximates()
					
					var options = mediator.proximates.filter(func(a): return a.biome == supplier)
					fiefdom = options.pick_random()
					fiefdom.region.remove_fiefdom(fiefdom)
					mediator.add_fiefdom(fiefdom)
					mediator.update_proximates()
					
					if mediators[mediator].is_empty():
						mediators.erase(mediator)
				else:
					print("not full coast")
	
	for biome in biomes:
		biome.update_fiefdoms()
		
		for region in biome.regions:
			region.update_proximates()
	
func exchange_quadrats_biomes() -> void:
	var flag = true
	
	while flag:
		var _biomes = {}
		
		for biome in biomes:
			if biome.terrain != "coast":
				for region in biome.regions:
					var internals = region.get_internals()
					
					var quadrats = get_quadrats(internals)
					
					if !quadrats.is_empty():
						if !_biomes.has(biome):
							_biomes[biome] = {}
						
						_biomes[biome][region] = quadrats
		
		var options = _biomes.keys()
		
		if options.size() > 1:
			options.shuffle()
			flag = true
			
			var a = {}
			var b = {}
			a.biome = options.pop_back()
			b.biome = options.pop_back()
			a.region = _biomes[a.biome].keys().pick_random()
			b.region = _biomes[b.biome].keys().pick_random()
			a.quadrat = _biomes[a.biome][a.region].pick_random()
			b.quadrat = _biomes[b.biome][b.region].pick_random()
			
			a.region.separate(a.quadrat)
			b.region.separate(b.quadrat)
			
			a.biome.attach_region(b.quadrat) 
			b.biome.attach_region(a.quadrat) 
		else:
			flag = false
	
func get_quadrats(internals_: Array) -> Array:
	var quadrats = []
	
	for fiefdom in internals_:
		var quadrat = [fiefdom]
		
		for direction in Global.dict.direction.zero:
			if direction != Vector2i.ZERO:
				if fiefdom.direction_fiefdoms.has(direction):
					var neighbor = fiefdom.direction_fiefdoms[direction]
					
					if internals_.has(neighbor):
						quadrat.append(neighbor)
					else:
						break
				else:
					break
		
		if quadrat.size() == 4:
			quadrats.append(quadrat)
	
	return quadrats
#endregion
	
func init_gods() -> void:
	var ennobleds = get_ennobled_fiefdoms()
	
	for fiefdom in ennobleds:
		var god = god_scene.instantiate()
		world.heaven.add_god(god, fiefdom)
	
func get_ennobled_fiefdoms() -> Array:
	var ennobleds = []
	var _fiefdoms = fiefdoms.get_children().filter(func(a): return a.resource.is_border)
	var pairs = []
	
	for fiefdom in _fiefdoms:
		var flag = false
		
		for direction in fiefdom.direction_fiefdoms:
			var neighbor = fiefdom.direction_fiefdoms[direction]
			
			if neighbor.empire != fiefdom.empire and neighbor.resource.is_border:
				flag = true
				var pair = [fiefdom, neighbor]
				pair.sort_custom(func(a, b): return a.resource.index < b.resource.index)
				
				if !pairs.has(pair):
					pairs.append(pair)
				
				break
	
	for pair in pairs:
		for fiefdom in pair:
			var a = {}
			a.fiefdom = pair[0]
			var b = {}
			b.fiefdom = pair[1]
			var axis = 0
			
			if a.fiefdom.resource.grid.x == b.fiefdom.resource.grid.x:
				if a.fiefdom.resource.grid.x == 0:
					axis = 3
				else:
					axis = 1
			else:
				if a.fiefdom.resource.grid.y == 0:
					axis = 0
				else:
					axis = 2
			
			var s = Global.dict.direction.linear2.size()
			var clockwises = [-1, -1, 1, 1]
			a.clockwise = clockwises[axis]
			var _axis = (axis + s / 2) % s
			b.clockwise = clockwises[_axis]
			
			a.dukedom = a.fiefdom.dukedom
			b.dukedom = b.fiefdom.dukedom
			
			var datas = [a, b]
			
			for data in datas:
				var flag = false
				var counter = 2
				
				while !flag or counter > 0:
					counter -= 1
					data.fiefdom = get_shifted_border_fiefdom_(data.fiefdom, data.clockwise)
					
					if counter <= 0:
						if data.fiefdom.dukedom != data.dukedom:
							flag = data.fiefdom.biome.terrain == "coast"
				
				ennobleds.append(data.fiefdom)
	return ennobleds
	
func get_shifted_border_fiefdom_(fiefdom_: Fiefdom, shift_: int) -> Fiefdom:
	if !fiefdom_.resource.is_border:
		return fiefdom_
	
	var grid = fiefdom_.resource.grid
	var corners = [0, n - 1]
	var axis = []
	
	var pairs = [
		[1, 2],
		[1, 3],
		[2, 3],
		[2, 0],
		[3, 0],
		[3, 1],
		[0, 1],
		[0, 2]
	]
	
	if corners.has(grid.x) and corners.has(grid.y):
		if grid.x == 0:
			if grid.y == 0:
				axis = 0
			else:
				axis = 6
		else:
			if grid.y == 0:
				axis = 2
			else:
				axis = 4
	else:
		if corners.has(grid.x):
			if grid.x == 0:
				axis = 7
			else:
				axis = 3
		
		if corners.has(grid.y):
			if grid.y == 0:
				axis = 1
			else:
				axis = 5
	
	var direction = Global.dict.direction.linear2[pairs[axis][0]]
	
	if shift_ == -1:
		direction = Global.dict.direction.linear2[pairs[axis][1]]
	
	return fiefdom_.direction_fiefdoms[direction]
	
func init_thickets() -> void:
	var thicket = 0
	var capitals = []
	wave.clear()
	
	for god in world.heaven.gods:
		capitals.append(god.territory.capital)
		#print(god.territory.proximates)
		var proximates = god.territory.proximates.filter(func(a): return !wave.has(a))
		wave.append_array(proximates)
	
	var unvisiteds = fiefdoms.get_children().filter(func(a): return !a.resource.is_locked and !capitals.has(a))
	
	while !wave.is_empty() and thicket < Global.num.thicket.limit * 2:
		thicket += 1
		var next_wave = []
		
		for fiefdom in wave:
			unvisiteds.erase(fiefdom)
			fiefdom.thicket = min(thicket, Global.num.thicket.limit)
		
		while !wave.is_empty():
			var fiefdom = wave.pop_back()
			
			for neighbor in fiefdom.neighbors:
				if unvisiteds.has(neighbor) and !next_wave.has(neighbor):##unvisiteds.has(neighbor)
					next_wave.append(neighbor)
		
		wave.append_array(next_wave)
	shift_to_thicket_layer()
	
func shift_domain_layer(shift_: int ) -> void:
	var index = (Global.arr.titulus.find(layer) + shift_ + Global.arr.titulus.size()) % Global.arr.titulus.size()
	layer = Global.arr.titulus[index]
	var domains = get(layer + "s")
	
	for domain in domains:
		domain.recolor_fiefdoms()
	
func shift_to_terrain_layer() -> void:
	for biome in biomes:
		biome.recolor_fiefdoms()
	
func shift_to_thicket_layer() -> void:
	for fiefdom in fiefdoms.get_children():
		if fiefdom.thicket != -1:
			var s = 1
			
			if fiefdom.thicket != 0:
				var gap = 3
				s -= float(fiefdom.thicket + gap) / (Global.num.thicket.limit + gap)
			
			fiefdom.color = Color.from_hsv(0, 0, s)
	
func _input(event) -> void:
	if event is InputEventKey:
		if event.is_pressed() && !event.is_echo():
			match event.keycode:
				KEY_A:
					shift_domain_layer(-1)
				KEY_D:
					shift_domain_layer(1)
				KEY_Q:
					shift_to_terrain_layer()
				KEY_E:
					shift_domain_layer(0)
				KEY_X:
					shift_to_thicket_layer()
				KEY_Z:
					pass
				KEY_C:
					pass
				KEY_SPACE:
					mediator_coast_biomes()
	
