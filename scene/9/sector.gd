class_name Sector extends Node2D


@export var map: Map:
	set(map_):
		map = map_
		
		index = int(Global.num.index.sector)
		Global.num.index.sector += 1
		color = Color.from_hsv(float(index) / 24, 1.0, 1.0)
		init_fiefdoms()
	get:
		return map
@export var index: int
@export var dimensions: Vector2i
@export var grid: Vector2i
@export var color: Color

@export var fiefdoms: Array[Fiefdom]


func init_fiefdoms() -> void:
	for _y in dimensions.y:
		for _x in dimensions.x:
			var _grid = Vector2i(grid) + Vector2i(_x, _y)
			var fiefdom = map.grids[_grid]
			add_fiefdom(fiefdom)
	
func add_fiefdom(fiefdom_: Fiefdom) -> void:
	fiefdoms.append(fiefdom_)
	fiefdom_.sectors.append(self)
	
func push_proximates() -> void:
	var proximates = []
	
	for fiefdom in fiefdoms:
		for direction in fiefdom.direction_fiefdoms:
			var neighbor = fiefdom.direction_fiefdoms[direction]
			
			if !neighbor.sectors.has(self) and !proximates.has(neighbor):
				proximates.append(neighbor)
	
	for fiefdom in proximates:
		if !fiefdom.resource.is_locked:
			add_fiefdom(fiefdom)
	
func recolor_fiefdoms() -> void:
	for fiefdom in fiefdoms:
		fiefdom.color = color
