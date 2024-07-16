class_name Map extends Node2D


@export var earldoms: Array[Domain]
@export var dukedoms: Array[Domain]
@export var kingdoms: Array[Domain]
@export var empires: Array[Domain]
@export var grids: Dictionary

@onready var fiefdom_scene = preload("res://scene/6/fiefdom.tscn")
@onready var domain_scene = preload("res://scene/6/domain.tscn")
@onready var fiefdoms = %Fiefdoms

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
	init_fiefdoms()
	init_fiefdoms_neighbors()
	init_empires()
	init_kingdoms()
	
func init_fiefdoms() -> void:
	for _i in n:
		for _j in n:
			var fiefdom = fiefdom_scene.instantiate()
			fiefdom.resource.grid = Vector2i(_j, _i)
			fiefdom.map = self
			fiefdoms.add_child(fiefdom)
	
func init_fiefdoms_neighbors() -> void:
	for fiefdom in fiefdoms.get_children():
		if !fiefdom.resource.is_locked:
			for direction in Global.dict.direction.linear2:
				var grid = fiefdom.resource.grid + direction
				
				if grids.has(grid):
					var neighbor = grids[grid]
					
					if !neighbor.resource.is_locked:
						neighbor.neighbors.append(fiefdom)
						fiefdom.neighbors.append(neighbor)
	
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
	
