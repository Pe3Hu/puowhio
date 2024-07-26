class_name Territory extends PanelContainer


@export var god: God

@export var capital: Fiefdom:
	set(capital_):
		capital = capital_
		capital.thicket = 0
		set_fiefdom_as_external(capital)
	get:
		return capital

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
				proximates.append(neighbor)
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
	
func recolor_fiefdoms() -> void:
	for fiefdom in proximates:
		fiefdom.color.a = 0.2
	
	for fiefdom in externals:
		fiefdom.color.a = 0.5
	
	for fiefdom in internals:
		fiefdom.color.a = 0.8
