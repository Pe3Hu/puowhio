class_name Map extends Node2D


@export var earldoms: Array[Domain]
@export var dukedoms: Array[Domain]
@export var kingdoms: Array[Domain]
@export var empires: Array[Domain]
@export var grids: Dictionary
@export var rings: Dictionary

@onready var fiefdom_scene = preload("res://scene/6/fiefdom.tscn")
@onready var trail_scene = preload("res://scene/6/trail.tscn")
@onready var domain_scene = preload("res://scene/7/domain.tscn")
@onready var deadend_scene = preload("res://scene/7/deadend.tscn")
@onready var frontier_scene = preload("res://scene/7/frontier.tscn")
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


func _ready() -> void:
	if false:
		return
	pass
	init_fiefdoms()
	init_trails()
	
	init_earldoms()
	init_dukedoms()
	#init_fiefdoms_neighbors()
	#init_empires()
	#init_kingdoms()
	
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
		
		#print([counter, consumer.fiefdoms.size(), donor.fiefdoms.size()])
	
func init_trails() -> void:
	for fiefdom in fiefdoms.get_children():
		if !fiefdom.resource.is_locked:
			for direction in Global.dict.direction.windrose:
				var grid = fiefdom.resource.grid + direction
				
				if grids.has(grid):
					var neighbor_fiefdom = grids[grid]
					
					if !fiefdom.neighbors.has(neighbor_fiefdom) and !neighbor_fiefdom.resource.is_locked:
						var trail = trail_scene.instantiate()
						trail.map = self
						trail.direction = direction
						trails.add_child(trail)
						var pair: Array[Fiefdom]#[fiefdom, neighbor_fiefdom]
						#trail.fiefdoms = Array[Fiefdom]
						pair.append(fiefdom)
						pair.append(neighbor_fiefdom)
						trail.fiefdoms = pair
						pass
	
	clear_intersecting_trails()
	clear_redundant_trails()
	#clear_border_trails()
	
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
				
				if fiefdom.directions.has(direction):
					var trail = fiefdom.directions[direction]
					options.append(trail)
					
					grid.x += 1
					fiefdom = grids[grid]
				
				direction = Vector2i(-1, 1)
				
				if fiefdom.directions.has(direction):
					var trail = fiefdom.directions[direction]
					options.append(trail)
				
				if !options.is_empty():
					var option = options.pick_random()
					option.crush()
	
	for _i in exceptions.size():
		var grid = exceptions[_i] + offsets[_i]
		var fiefdom = grids[grid]
		var direction = directions[_i]
		var trail = fiefdom.directions[direction]
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
	
func init_earldoms() -> void:
	for fiefdom in fiefdoms.get_children():
		var domain = domain_scene.instantiate()
		domain.map = self
		domain.layer = "earldom"
		earldoms.append(domain)
		domain.add_fiefdom(fiefdom)
	
	init_frontiers("earldom")
	
func init_frontiers(layer_: String) -> void:
	frontiers[layer_] = {}
	var domains = get(layer_ + "s")
	
	for domain in domains:
		if !frontiers[layer_].has(domain):
			frontiers[layer_][domain] = {}
		
		for fiefdom in domain.perimeter.proximates:
			var neighbor_domain = fiefdom.get(layer_)
			
			if !frontiers[layer_][domain].has(neighbor_domain):
				var frontier = frontier_scene.instantiate()
				frontier.domains = [domain, neighbor_domain]
				frontier.map = self
	
func init_dukedoms() -> void:
	wave.clear()
	var layer_ = "dukedom"
	var vassal_layer = Global.dict.vassal[layer_]
	var m = Global.num.trail.max + 2
	var corners = [0, n - 1]
	
	for _i in corners:
		for _j in corners:
			var grid = Vector2i(_j, _i)
			var fiefdom = grids[grid]
			wave.append(fiefdom.get(vassal_layer))
	
	var stopper = 1
	var _i = 0
	var domains = get(layer_ + "s")
	
	#for _i in 60:#dukedom_count
	while _i < stopper:
		_i += 1
		
		if wave.is_empty():
			stopper = 0
		else:
			var domain = domain_scene.instantiate()
			domain.map = self
			domain.layer = layer_
			domains.append(domain)
			
			if deadends.get_child_count() == 0:
				var vassal = wave.pick_random()
				domain.add_vassal(vassal)
				#wave.erase(vassal)
				domain.apply_flood_fill()
			
				if domain.vassals.size() != get(layer_ + "_vassals"):
					stopper = 0
			else:
				var deadend = deadends.get_children().pick_random()
				deadend.establish_domain()
			
			print([_i, deadends.get_child_count()])
	
	for domain in domains:
		domain.recolor_fiefdoms()
		
	for deadends in deadends.get_children():
		deadends.paint_black()
		
		#print(domain.fiefdoms.size())
	
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
				print("D", domain.fiefdoms[0].resource.grid)
	
	for _i in range(deadends.get_child_count() - 1, -1 -1):
		var deadend = deadends.get_child(_i)
		
		if deadend.root.get(layer_) != null:
			deadend.crush()
	
	merge_deadends(layer_)
	extend_deadends(layer_)
	
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
		
	for _i in range(deadends.get_child_count() - 1, -1 -1):
		var deadend = deadends.get_child(_i)
		var options = deadend.branches.filter(func(a): return a.deadends.is_empty())
		
		if options.size() == 1:
			is_connected = false
			deadend.is_connected = false
			deadend.fill_chain()
		
	if !is_connected:
		find_deadends(layer_)
	
