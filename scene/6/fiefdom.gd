class_name Fiefdom extends Polygon2D


@export var map: Map:
	set(map_):
		map = map_
		
		position = Global.vec.window.center + Vector2(map.earldom_size) * (Vector2(resource.grid) - Vector2.ONE * map.n * 0.5 + Vector2.ONE * 0.5)
		init_vertexs()
		map.grids[resource.grid] = self
		resource.ring = max(abs(map.r - resource.grid.x), abs(map.r - resource.grid.y))
		map.rings[resource.ring].append(self)
		#color = Color.from_hsv(float(resource.ring) / map.rings, 1, 1)
		#map.earldoms.append(resource)
	get:
		return map
var resource: FiefdomResource = FiefdomResource.new()

var neighbors: Dictionary
var trails: Dictionary
var direction_trails: Dictionary
var direction_fiefdoms: Dictionary

var index_color: Color
var domains: Array[Domain]

var earldom: Domain
var dukedom: Domain
var kingdom: Domain
var empire: Domain

var biomes: Array[Biome]
var biome: Biome
var sectors: Array[Sector]
var region: Region
var territory: Territory
var thicket: int = -1


func reset() -> void:
	domains.clear()
	
	for state in Global.arr.titulus:
		set(state, null)
	
func init_vertexs() -> void:
	var vertexs = []
	
	for direction in Global.dict.direction.linear2:
		var vertex = Vector2(direction) * Vector2(map.earldom_size) / 2 * 0.66
		vertexs.append(vertex)
	
	set_polygon(vertexs)
	index_color =  Color.from_hsv(resource.index / 360.0, 0.7, 0.9)
	#color = index_color
	#print(Vector2i.ONE * floor(map.n / 2), resource.grid)
	
	if resource.grid.x == 0 or resource.grid.x == map.n - 1 or resource.grid.y == 0 or resource.grid.y == map.n - 1:
		resource.is_border = true
	
	if Vector2i.ONE * floor(map.n / 2) == resource.grid:
		resource.is_locked = true
		visible = false
