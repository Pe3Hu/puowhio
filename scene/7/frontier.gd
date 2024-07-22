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
		init_trails()
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
	
func init_trails() -> void:
	trails.clear()
	var a = domains[0]
	var b = domains[1]
	
	for fiefdom in a.fiefdoms:
		for neighbor in fiefdom.neighbors:
			if b.fiefdoms.has(neighbor):
				var trail = fiefdom.neighbors[neighbor]
				
				if !trails.has(trail):
					trails.append(trail)
