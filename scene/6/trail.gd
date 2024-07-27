class_name Trail extends Line2D


@export var map: Map:
	set(map_):
		map = map_
		
		if !map.is_seed:
			index = int(Global.num.index.trail)
			Global.num.index.trail += 1
	get:
		return map

@export var fiefdoms: Array[Fiefdom]:
	set(fiefdoms_):
		fiefdoms = fiefdoms_
		
		for fiefdom in fiefdoms:
			var vertex = fiefdom.position
			add_point(vertex)
		
		fiefdoms[0].neighbors[fiefdoms[1]] = self
		fiefdoms[1].neighbors[fiefdoms[0]] = self
		fiefdoms[0].trails[self] = fiefdoms[1]
		fiefdoms[1].trails[self] = fiefdoms[0]
		
		if !fiefdoms[0].direction_trails.has(direction):
			fiefdoms[0].direction_trails[direction] = self
			#fiefdoms[0].direction_fiefdoms[direction] = fiefdoms[1]
			var index = Global.dict.direction.windrose.find(direction)
			var n = Global.dict.direction.windrose.size()
			index = (index + n / 2) % n
			fiefdoms[1].direction_trails[Global.dict.direction.windrose[index]] = self
			#fiefdoms[1].direction_fiefdoms[Global.dict.direction.windrose[index]] = fiefdoms[0]
	get:
		return fiefdoms
@export var resource: FiefdomResource = FiefdomResource.new()

@export var index: int
@export var direction: Vector2i


func crush() -> void:
	for fiefdom in fiefdoms:
		for _direction in fiefdom.direction_trails:
			if fiefdom.direction_trails[_direction] == self:
				fiefdom.direction_trails.erase(_direction)
		
		for neighbor in fiefdom.neighbors:
			if fiefdom.neighbors[neighbor] == self:
				fiefdom.neighbors.erase(neighbor)
		
		fiefdom.trails.erase(self)
	
	map.trails.remove_child(self)
	queue_free()
