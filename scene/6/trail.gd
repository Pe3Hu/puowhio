class_name Trail extends Line2D


@export var map: Map:
	set(map_):
		map = map_
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
		fiefdoms[0].directions[direction] = self
		var index = Global.dict.direction.windrose.find(direction)
		var n = Global.dict.direction.windrose.size()
		index = (index + n / 2) % n
		fiefdoms[1].directions[Global.dict.direction.windrose[index]] = self
	get:
		return fiefdoms
@export var resource: FiefdomResource = FiefdomResource.new()
@export var direction: Vector2i


func crush() -> void:
	for fiefdom in fiefdoms:
		for direction in fiefdom.directions:
			if fiefdom.directions[direction] == self:
				fiefdom.directions.erase(direction)
		
		for neighbor in fiefdom.neighbors:
			if fiefdom.neighbors[neighbor] == self:
				fiefdom.neighbors.erase(neighbor)
		
		fiefdom.trails.erase(self)
	
	map.trails.remove_child(self)
	queue_free()
