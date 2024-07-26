class_name Biome extends Node2D


@export var map: Map:
	set(map_):
		map = map_
		
		init_region()
	get:
		return map

@export var terrain: String

@export var options: Array[Fiefdom]
@export var fiefdoms: Array[Fiefdom]
@export var regions: Array[Region]


func recolor_fiefdoms() -> void:
	for region in regions:
		region.recolor_fiefdoms()
	
func init_region() -> void:
	var region = map.region_scene.instantiate()
	region.biome = self
	regions.append(region)
	
	if terrain != "coast":
		var weights = {}
		
		for option in options:
			weights[option] = option.resource.ring
		options.sort_custom(func(a, b): return a.resource.ring > b.resource.ring)
		var _options = options.filter(func (a): return a.resource.ring == options[0].resource.ring)
		options.sort_custom(func(a, b): return weights[a] > weights[b])
		options = options.filter(func (a): return weights[a] == weights[options[0]])
		var fiefdom = _options.pick_random()
		region.add_fiefdom(fiefdom)
	
func region_expansion() -> void:
	var region = regions[regions.size() - 1]
	region.expansion()
	
func attach_region(fiefdoms_: Array) -> void:
	var region = map.region_scene.instantiate()
	region.biome = self
	regions.append(region)
	
	for fiefdom in fiefdoms_:
		region.add_fiefdom(fiefdom)
	
	update_fiefdoms()
	
func update_fiefdoms() -> void:
	fiefdoms.clear()
	
	for region in regions:
		fiefdoms.append_array(region.externals)
		region.update_proximates()
	
func tide(waves_: int) -> int:
	var coast = map.biomes[5].regions[0]
	#var borders = fiefdoms.filter(func (a): return a.resource.is_border)
	var uniques = []
	
	var _options = {} 
	#for fiefdom in borders:
		#if !weigths.has(fiefdom.region):
			#weigths[fiefdom.region] = []
	
	for region in regions:
		_options[region] = region.externals.filter(func (a): return a.resource.is_border)
		_options[region].shuffle()
		#print([terrain, _options[region].size()])
		
		if _options[region].is_empty():
			_options.erase(region)
		else:
			for border in _options[region]:
				if !uniques.has(border):
					uniques.append(border)
				#print(border.resource.grid)
	
	#print([terrain, uniques.size(), borders.size()])
	for _i in waves_:
		if _options.is_empty():
			return _i
			
		var _regions = _options.keys()
		_regions.sort_custom(func(a, b): return _options[a] > _options[b])
		var region = _regions[0]
		var fiefdom = _options[region].pop_back()
		region.remove_fiefdom(fiefdom)
		coast.add_fiefdom(fiefdom)
		
		if _options[region].is_empty():
			_options.erase(region)
		
		if _options.is_empty():
			return _i + 1
	
	return waves_
