class_name Map extends Node2D


@export var earldoms: Array[Domain]
@export var dukedoms: Array[Domain]
@export var kingdoms: Array[Domain]
@export var empires: Array[Domain]
@export var grids: Dictionary

@onready var fiefdom_scene = preload("res://scene/6/fiefdom.tscn")
@onready var trail_scene = preload("res://scene/6/trail.tscn")
@onready var domain_scene = preload("res://scene/6/domain.tscn")
@onready var fiefdoms = %Fiefdoms
@onready var trails = %Trails

#const earldom_l = 40
const earldom_size = Vector2i(40, 40)
const n = 19
const k = 361

const empire_count = 3
const kingdom_count = 12
const dukedom_count = 60

const empire_vassals = 4
const kingdom_vassals = 5
const dukedom_vassals = 6

const empire_fiefdoms = 120
const kingdom_fiefdoms = 30
const dukedom_fiefdoms = 6


func _ready() -> void:
	pass
	init_fiefdoms()
	init_trails()
	
	init_dukedoms()
	#init_fiefdoms_neighbors()
	#init_empires()
	#init_kingdoms()
	
func init_fiefdoms() -> void:
	for _i in n:
		for _j in n:
			var fiefdom = fiefdom_scene.instantiate()
			fiefdom.resource.grid = Vector2i(_j, _i)
			fiefdom.map = self
			fiefdoms.add_child(fiefdom)
	
func init_empires() -> void:
	Global.rng.randomize()
	var start_angle = Global.rng.randf_range(0, PI * 2)
	var angle_step = PI * 2 / empire_count
	
	for _i in empire_count:
		var domain = domain_scene.instantiate()
		domain.map = self
		domain.layer = "empire"
		empires.append(domain)
		
		Global.rng.randomize()
		var l = Global.rng.randf_range(n * 0.125, n * 0.375)
		var angle = start_angle + angle_step * _i
		var grid = Vector2i(Vector2.from_angle(angle) * l) + Vector2i.ONE * floor(n / 2)
		var fiefdom = grids[grid]
		domain.add_fiefdom(fiefdom)
	
	roll_layer_lazy_flood_fill("empire")
		
	for domain in empires:
		domain.recolor_fiefdoms()
		print(domain.fiefdoms.size())
	
func init_kingdoms() -> void:
	for domain in empires:
		domain.init_vassals()
	#roll_layer_lazy_flood_fill("kingdom")
	
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
	
func clear_intersecting_trails() -> void:
	var k = int(n - 2)
	var exceptions = []
	exceptions.append(Vector2i(0, 0))
	exceptions.append(Vector2i(k, 0))
	exceptions.append(Vector2i(k, k))
	exceptions.append(Vector2i(0, k))
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
		var n = fiefdom.trails.keys().size()
		
		if n > Global.num.trail.min:
			if !redundants.has(n):
				redundants[n] = []
				
				if maximum < n:
					maximum = int(n)
			
			redundants[n].append(fiefdom)
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
	
func init_dukedoms() -> void:
	var contacts = {}
	contacts.count = {}
	contacts.fiefdom = {}
	contacts.corner = []
	var m = Global.num.trail.max + 2
	var corners = [0, n - 1]
	
	for _i in corners:
		for _j in corners:
			var grid = Vector2i(_j, _i)
			var fiefdom = grids[grid]
			contacts.corner.append(fiefdom)
	
	for _i in m:
		contacts.count[_i] = []
	
	for fiefdom in fiefdoms.get_children():
		if !fiefdom.resource.is_locked:
			var n = fiefdom.neighbors.keys().size()
			contacts.count[n].append(fiefdom)
			contacts.fiefdom[fiefdom] = fiefdom.neighbors.keys()
			#contacts[fiefdom].append_array(fiefdom.neighbors.keys())
			
			if n > Global.num.trail.max:
				fiefdom.color = Color.BLACK
	
	for _i in 1:#dukedom_count
		var domain = domain_scene.instantiate()
		domain.map = self
		domain.layer = "dukedom"
		dukedoms.append(domain)
		
		#var min_contacts = null
		#
		#for _j in range(1, k, 1):
			#if !contacts.count[_j].is_empty():
				#min_contacts = _j
				#break
		
		var options = []
		options.append_array(contacts.corner)
		options.sort_custom(func(a, b): return contacts.fiefdom[a].size() < contacts.fiefdom[b].size())
		var k = contacts.fiefdom[options.front()].size()
		options = options.filter(func (a): return contacts.fiefdom[a].size() == k)
		#options = contacts.count[min_contacts].filter(func (a): return contacts.corner.has(a))
		var fiefdom = options.pick_random()
		contacts.corner.erase(fiefdom)
		domain.add_fiefdom(fiefdom)
		cross_out(contacts, fiefdom)
		domain.apply_flood_fill(contacts)
		
	for domain in dukedoms:
		domain.recolor_fiefdoms()
		#print(domain.fiefdoms.size())
	
func cross_out(contacts_: Dictionary, fiefdom_: Fiefdom) -> void:
	if !contacts_.fiefdom.has(fiefdom_):
		pass
	var n = contacts_.fiefdom[fiefdom_].size()
	contacts_.count[n].erase(fiefdom_)
	
	for neighbor_fiefdom in contacts_.fiefdom[fiefdom_]:
		n = contacts_.fiefdom[neighbor_fiefdom].size()
		contacts_.count[n].erase(neighbor_fiefdom)
		n -= 1
		contacts_.fiefdom[neighbor_fiefdom].erase(fiefdom_)
		
		if n > 0:
			contacts_.count[n].append(neighbor_fiefdom)
	
	contacts_.fiefdom.erase(fiefdom_)
