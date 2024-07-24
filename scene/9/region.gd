class_name Region extends Node2D


@export var biome: Biome

@export var proximates: Array[Fiefdom]
@export var externals: Array[Fiefdom]


func add_fiefdom(fiefdom_: Fiefdom) -> void:
	#if proximates.has(fiefdom_):
	#	proximates.erase(fiefdom_)
	
	if fiefdom_.region != null:
		pass
	externals.append(fiefdom_)
	fiefdom_.biome = biome
	fiefdom_.region = self
	
	for direction in fiefdom_.direction_fiefdoms:
		var neighbor = fiefdom_.direction_fiefdoms[direction]
		
		if neighbor.region == null and neighbor.biomes.has(biome):
			if !proximates.has(neighbor) and !externals.has(neighbor):
				proximates.append(neighbor)
	
	for _biome in fiefdom_.biomes:
		_biome.options.erase(fiefdom_)
		
		for region in _biome.regions:
			if region.proximates.has(fiefdom_):
				region.proximates.erase(fiefdom_)
	
func recolor_fiefdoms() -> void:
	for fiefdom in externals:
		fiefdom.color = Global.color.terrain[biome.terrain]
	
func expansion() -> void:
	if !proximates.is_empty():
		var weights = {}
		
		for fiefdom in proximates:
			weights[fiefdom] = 0
			
			for direction in fiefdom.direction_fiefdoms:
				var neighbor = fiefdom.direction_fiefdoms[direction]
				
				if externals.has(neighbor):
					weights[fiefdom] += 1
		
		var options = proximates.duplicate()
		options.sort_custom(func(a, b): return weights[a] > weights[b])
		options = options.filter(func (a): return weights[a] == weights[options[0]])
		var fiefdom = options.pick_random()
		add_fiefdom(fiefdom)
