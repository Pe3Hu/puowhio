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
@export var resource: FiefdomResource = FiefdomResource.new()

@export var neighbors: Dictionary
@export var trails: Dictionary
@export var directions: Dictionary

@export var index_color: Color
@export var domains: Array[Domain]

@export var earldom: Domain
@export var barony: Domain
@export var dukedom: Domain
@export var kingdom: Domain
@export var empire: Domain

func init_vertexs() -> void:
	var vertexs = []
	
	for direction in Global.dict.direction.linear2:
		var vertex = Vector2(direction) * Vector2(map.earldom_size) / 2 * 0.66
		vertexs.append(vertex)
	
	set_polygon(vertexs)
	index_color =  Color.from_hsv(resource.index / 360.0, 0.7, 0.9)
	#color = index_color
	#print(Vector2i.ONE * floor(map.n / 2), resource.grid)
	if Vector2i.ONE * floor(map.n / 2) == resource.grid:
		resource.is_locked = true
		visible = false
