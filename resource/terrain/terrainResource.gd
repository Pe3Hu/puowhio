class_name TerrainResource extends Resource


@export_enum("swamp", "plain", "desert", "mountain", "tundra", "coast", "volcano", "jungle") var title: String
@export_range(1.0, 1.3, 0.1) var aqua: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export_range(1.0, 1.3, 0.1) var wind: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export_range(1.0, 1.3, 0.1) var fire: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export_range(1.0, 1.3, 0.1) var earth: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export_range(1.0, 1.3, 0.1) var ice: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export_range(1.0, 1.3, 0.1) var storm: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export_range(1.0, 1.3, 0.1) var lava: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export_range(1.0, 1.3, 0.1) var nature: float = 1:
	set(value_):
		aqua = value_
		update_element("aqua")
	get:
		return aqua
@export var elements: Array[String]


func update_element(element_: String) -> void:
	if get(element_) > 1.0:
		elements.append(element_)
	else:
		if elements.has(element_):
			elements.erase(element_)
