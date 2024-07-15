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
			%Icon.custom_inimum_size = cell_size
			%Label.custom_minimum_size = Vector2(cell_size.x * 2, base_cell_size.y)
	get:
		return cell_size

const base_cell_size = Vector2(21, 21)


func recolor(flag_: bool) -> void:
	var color = Color.from_hsv(0, 0, 0.2)
	
	if flag_:
		color = Global.color.aspect[resource.subtype]
		
	%Icon.modulate = color
	%Label.set("theme_override_colors/font_color", color)
	
func set_from_doublet(resource_: DoubletResource) -> void:
	resource = resource_
	update_ui()
	update_label()
	
func update_ui() -> void:
	var _path = resource.type
	var _name = resource.subtype
	
	if resource.type == "parameter":
		_name += " " + resource.measure
		
	%Icon.texture = load("res://asset/png/" + _path +  "/" + _name + ".png")
	
	if resource.type == "aspect":
		recolor(resource.time == "temporary")
	
func update_label() -> void:
	%Label.text = str(resource.value)
	
	if resource.measure == "multiplier" or resource.measure == "chance":
		%Label.text += "%"
