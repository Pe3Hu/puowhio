@tool
class_name Doublet extends PanelContainer


@export var panel: PanelContainer

@export var resource: DoubletResource:
	set(resource_):
		resource = resource_
		
		if is_node_ready():
			update_ui()
	get:
		return resource

@export_range(1, 4, 1) var zoom: int = 1:
	set(zoom_):
		zoom = zoom_
		
		cell_size = base_cell_size * (zoom)
	get:
		return zoom

@export var cell_size: Vector2 = base_cell_size:
	set(cell_size_):
		cell_size = cell_size_
		
		if is_node_ready():
			%Icon.custom_minimum_size = cell_size
			%Label.custom_minimum_size = Vector2(cell_size.x * 2, base_cell_size.y)
	get:
		return cell_size

@export var value: int = 0:
	set(value_):
		value = value_
		%Label.text = str(value)
		
		if resource.measure == "percentage":
			%Label.text += "%"
	get:
		return value

const base_cell_size = Vector2(21, 21)


func recolor(flag_: bool) -> void:
	var color = Color.from_hsv(0, 0, 0.2)
	
	if flag_:
		color = Global.color.aspect[resource.icon_name]
		
	%Icon.modulate = color
	%Label.set("theme_override_colors/font_color", color)
	
func set_from_base(resource_: BaseResource) -> void:
	resource = load("res://resource/aspect/" + resource_.aspect + ".tres")
	update_ui()
	value = resource_.value
	
func set_from_affix(resource_: AffixResource) -> void:
	resource = load("res://resource/parameter/" + resource_.parameter + ".tres")
	update_ui()
	value = resource_.value
	
func update_ui() -> void:
	var _path = resource.type
	var _name = resource.icon_name
	
	if resource.type == "aspect" and _name.contains("modifier"):
		_path = "aspect"
		_name = _name.split(" ")[0]
		
	%Icon.texture = load("res://asset/png/" + _path +  "/" + _name + ".png")
	
	if value == 0 and %Label.text == "":
		value = resource.base
	
		if resource.measure == "percentage":
			%Label.text += "%"
	
	if resource.type == "aspect":
		recolor(resource.time == "temporary")
