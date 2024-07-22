class_name Deadend extends Node2D


@export_enum("dukedom", "kingdom", "empire") var layer: = "dukedom":
	set(layer_):
		layer = layer_
	get:
		return layer

@export var map: Map
@export var root: Domain
@export var chain: Array[Domain]
@export var branches: Array[Domain]
@export var is_connected: bool = false
#@export var domains: Array[Domain]

@onready var domain_scene = preload("res://scene/7/domain.tscn")


func _ready() -> void:
	map.roots[root] = self
	root.deadends.append(self)
	fill_chain()
	paint_black()
	
func fill_chain() -> void:
	var vassal_layer = Global.dict.vassal[layer]
	
	while !is_connected:
		if chain.is_empty():
			chain.append(root)
		
		var domain = chain.back()
		var neighbors = domain.perimeter.proximates.filter(func (a): return a.get(layer) == null)
		neighbors = neighbors.filter(func (a): return a.get(vassal_layer).deadends.is_empty())
		
		if neighbors.size() == 1:
			var vassal_domain = neighbors[0].get(vassal_layer)
			chain.append(vassal_domain)
			vassal_domain.deadends.append(self)
		else:
			for neighbor in neighbors:
				branches.append(neighbor.get(vassal_layer))
			
			is_connected = true
	
func paint_black() -> void:
	var v = float(get_index() + 1) / (map.deadends.get_child_count() + 2)
	
	for domain in chain:
		for fiefdom in domain.fiefdoms:
			fiefdom.color = Color.BLACK
			fiefdom.color.v = v
	
func crush() -> void:
	for domain in chain:
		domain.deadends.erase(self)
		
		if domain.deadends.is_empty():
			if map.roots.has(domain):
				map.roots.erase(domain)
	
	map.deadends.remove_child(self)
	queue_free()
	
func establish_domain() -> void:
	#var senor_layer = get()
	var domains = map.get(layer + "s")
	var domain = domain_scene.instantiate()
	domain.map = map
	domain.layer = layer
	domains.append(domain)
	
	for vassal in chain:
		domain.add_vassal(vassal)
	
	domain.apply_flood_fill()

	if domain.vassals.size() != map.get(layer + "_vassals"):
		print("establish_domain error")
	
	crush()
	
func pick_branch() -> void:
	if chain.size() < map.get(layer + "_vassals"):
		var options = branches.filter(func(a): return a.deadends.is_empty())
		
		if !options.is_empty():
			var vassal_domain = options.pick_random()
			chain.append(vassal_domain)
			vassal_domain.deadends.appends(self)
		else:
			return
	
func merge(deadend_: Deadend) -> void:
	var self_options = branches.filter(func(a): return a.deadends.is_empty())
	var other_options = deadend_.branches.filter(func(a): return a.deadends.is_empty())
	
	if self_options.size() + other_options.size() > 0:
		if self_options.is_empty():
			for domain in chain:
				domain.deadends.append(deadend_)
			
			var last = deadend_.chain.pop_back()
			deadend_.chain.append_array(chain)
			deadend_.chain.append(last)
			crush()
		
		if other_options.is_empty():
			for domain in deadend_.chain:
				domain.deadends.append(self)
			
			var last = chain.pop_back()
			chain.append_array(deadend_.chain)
			chain.append(last)
			deadend_.crush()
	
