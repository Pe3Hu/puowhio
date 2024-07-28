class_name Territory extends PanelContainer


@export var god: God
@export var locations: VBoxContainer

@export var capital: Fiefdom:
	set(capital_):
		capital = capital_
		capital.thicket = 0
		set_fiefdom_as_external(capital)
	get:
		return capital

@onready var location_scene = preload("res://scene/12/location.tscn")

var proximates: Array[Fiefdom]
var externals: Array[Fiefdom]
var internals: Array[Fiefdom]


func set_fiefdom_as_external(fiefdom_: Fiefdom) -> void:
	if proximates.has(fiefdom_):
		proximates.erase(fiefdom_)
	
	externals.append(fiefdom_)
	
	for neighbor in fiefdom_.neighbors:
		if neighbor.territory != self:
			if !proximates.has(neighbor) and !internals.has(neighbor):
				set_fiefdom_as_proximate(neighbor)
		elif neighbor.territory != null:
			set_fiefdom_as_internal(neighbor)
	
func set_fiefdom_as_internal(fiefdom_: Fiefdom) -> void:
	if !externals.has(fiefdom_):
		return
	
	for neighbor in fiefdom_.neighbors:
		if proximates.has(neighbor):
			return
	
	externals.erase(fiefdom_)
	internals.append(fiefdom_)
	
func set_fiefdom_as_proximate(fiefdom_: Fiefdom) -> void:
	proximates.append(fiefdom_)
	var location = location_scene.instantiate()
	location.fiefdom = fiefdom_
	locations.add_child(location)
	#location.territory = self
	
func recolor_fiefdoms() -> void:
	for fiefdom in proximates:
		fiefdom.color.a = 0.2
	
	for fiefdom in externals:
		fiefdom.color.a = 0.5
	
	for fiefdom in internals:
		fiefdom.color.a = 0.8
	
func update_dangers() -> void:
	for location in locations.get_children():
		location.init_dangers()
