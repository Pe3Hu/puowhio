class_name Heaven extends PanelContainer


@export var world: World
@export var gods: VBoxContainer

@onready var god_scene = preload("res://scene/11/god.tscn")

#var gods: Array[God]


func _ready() -> void:
	init_gods()
	init_thickets()
	
func init_gods() -> void:
	var ennobleds = world.map.get_ennobled_fiefdoms()
	
	for fiefdom in ennobleds:
		add_god(fiefdom)
	
	var _god = gods.get_child(0)
	_god.birth()
	
func add_god(fiefdom_: Fiefdom) -> void:
	var god = god_scene.instantiate()
	gods.add_child(god)
	god.territory.capital = fiefdom_
	god.heaven = self
	#god_.territory.recolor_fiefdoms()
	
func init_thickets() -> void:
	var wave = world.map.wave
	var thicket = 0
	var capitals = []
	wave.clear()
	
	for god in gods.get_children():
		capitals.append(god.territory.capital)
		#print(god.territory.proximates)
		var proximates = god.territory.proximates.filter(func(a): return !wave.has(a))
		wave.append_array(proximates)
	
	var unvisiteds = world.map.fiefdoms.get_children().filter(func(a): return !a.resource.is_locked and !capitals.has(a))
	
	while !wave.is_empty() and thicket < Global.num.thicket.limit * 2:
		thicket += 1
		var next_wave = []
		
		for fiefdom in wave:
			unvisiteds.erase(fiefdom)
			fiefdom.thicket = min(thicket, Global.num.thicket.limit)
		
		while !wave.is_empty():
			var fiefdom = wave.pop_back()
			
			for neighbor in fiefdom.neighbors:
				if unvisiteds.has(neighbor) and !next_wave.has(neighbor):##unvisiteds.has(neighbor)
					next_wave.append(neighbor)
		
		wave.append_array(next_wave)
	
	world.map.shift_to_thicket_layer()
	
