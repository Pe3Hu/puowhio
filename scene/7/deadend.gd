class_name Deadend extends Node2D


@export_enum("dukedom", "kingdom", "empire") var layer: = "dukedom":
	set(layer_):
		layer = layer_
	get:
		return layer

@export var map: Map
@export var root: Domain
@export var chain: Array[Domain]
@export var is_connected: bool = false
#@export var domains: Array[Domain]

@onready var domain_scene = preload("res://scene/7/domain.tscn")


func _ready() -> void:
	map.roots[root] = self
	fill_chain()
	paint_black()

func fill_chain() -> void:
	var vassal_layer = Global.dict.vassal[layer]
	
	while !is_connected:
		if chain.is_empty():
			chain.append(root)
		
		var domain = chain.back()
		var neighbors = domain.perimeter.proximates.filter(func (a): return a.get(layer) == null)
		
		if neighbors.size() == 1:
			chain.append(neighbors[0].get(vassal_layer))
		else:
			is_connected = true
	
func paint_black() -> void:
	for domain in chain:
		for fiefdom in domain.fiefdoms:
			fiefdom.color = Color.BLACK
	
func crush() -> void:
	for domain in chain:
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
