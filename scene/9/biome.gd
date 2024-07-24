class_name Biome extends Node2D


@export var map: Map:
	set(map_):
		map = map_
	get:
		return map

@export var terrain: String

@export var options: Array[Fiefdom]
@export var regions: Array[Region]


func recolor_fiefdoms() -> void:
	for region in regions:
		region.recolor_fiefdoms()
	
func init_region() -> void:
	var region = map.region_scene.instantiate()
	region.biome = self
	regions.append(region)
	#var weights = {}
	#
	#for option in options:
		#weights[option] = option.resource.ring
	#options.sort_custom(func(a, b): return a.resource.ring < b.resource.ring)
	#var _options = options.filter(func (a): return a.resource.ring == options[0].resource.ring)
	#options.sort_custom(func(a, b): return weights[a] < weights[b])
	#options = options.filter(func (a): return weights[a] == weights[options[0]])
	var fiefdom = options.pick_random()
	region.add_fiefdom(fiefdom)
	
func region_expansion() -> void:
	var region = regions[regions.size() - 1]
	region.expansion()
