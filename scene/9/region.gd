class_name Region extends Node2D


@export var biome: Biome:
	set(biome_):
		biome = biome_
		
		index = int(Global.num.index.region)
		Global.num.index.region += 1
	get:
		return biome

@export var index: int

@export var proximates: Array[Fiefdom]
@export var externals: Array[Fiefdom]


func add_fiefdom(fiefdom_: Fiefdom) -> void:
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
	
func separate(fiefdoms_: Array) -> void:
	for fiefdom in fiefdoms_:
		remove_fiefdom(fiefdom)
	
	update_proximates()
	
func remove_fiefdom(fiefdom_: Fiefdom) -> void:
	externals.erase(fiefdom_)
	fiefdom_.biome = null
	fiefdom_.region = null
	
func update_proximates() -> void:
	proximates.clear()
	
	for fiefdom in externals:
		for direction in fiefdom.direction_fiefdoms:
			var neighbor = fiefdom.direction_fiefdoms[direction]
			
			if !proximates.has(neighbor) and !externals.has(neighbor):
				proximates.append(neighbor)
	
func replenish_biome(biome_: Biome, count_: int) -> int:
	for _i in count_:
		var weights = {}
		
		for proximate in proximates:
			if proximate.biome == biome_:
				if !weights.has(proximate.region):
					weights[proximate.region] = proximate.region.externals.size()
		
		if !weights.is_empty():
			var regions = weights.keys()
			regions.sort_custom(func(a, b): return weights[a] < weights[b])
			var region = regions[0]
			var _externals = externals.filter(func(a): return region.proximates.has(a))
			var fiefdom = _externals.pick_random()
			remove_fiefdom(fiefdom)
			update_proximates()
			region.add_fiefdom(fiefdom)
			region.update_proximates()
		else:
			return _i
	
	return count_
	
func get_internals() -> Array:
	var internals = []
	
	for fiefdom in externals:
		var flag = true
		if fiefdom.biome != biome:
			pass
		
		for direction in fiefdom.direction_fiefdoms:
			var parity = Global.dict.direction.windrose.find(direction) % 2
			
			if parity == 0:
				var neighbor = fiefdom.direction_fiefdoms[direction]
				
				if proximates.has(neighbor):
					flag = false
					break
		
		if flag:
			internals.append(fiefdom)
	
	return internals
