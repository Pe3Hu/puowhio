class_name FiefdomResource extends Resource


@export var grid: Vector2i:
	set(grid_):
		grid = grid_
		
		index = int(Global.num.index.fiefdom)
		Global.num.index.fiefdom += 1
		
		is_locked = grid == Vector2i.ONE * 19
	get:
		return grid
@export var is_locked: bool
@export var index: int
@export var ring: int

