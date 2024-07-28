class_name Nested extends PanelContainer


@export var panel: PanelContainer
@export var resource: NestedResource:
	set(resource_):
		resource = resource_
		#value = resource.value
		
		if is_node_ready():
			update_ui()
	get:
		return resource

@export var icon: TextureRect
@export var label: Label

const base_cell_size = Vector2(48, 48)


func set_from_nested(resource_: NestedResource) -> void:
	resource = resource_
	update_ui()
	update_label()
	
func update_ui() -> void:
	var _path = resource.type
	var _name = resource.subtype
	
	if resource.type == "parameter":
		_name += " " + resource.measure
		
	icon.texture = load("res://asset/png/" + _path +  "/" + _name + ".png")
	
func update_label() -> void:
	label.text = str(resource.value)
