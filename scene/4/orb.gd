@tool
class_name Orb extends PanelContainer


@export var slot: Slot

@export_enum("aqua", "wind", "fire", "earth", "ice", "storm", "lava", "nature") var element: String = "aqua":
	set(element_):
		element = element_
		
		if is_node_ready():
			icon_update()
	get:
		return element

@export var cell_size: Vector2 = base_size:
	set(cell_size_):
		cell_size = cell_size_
		
		if is_node_ready():
			custom_minimum_size = cell_size
	get:
		return cell_size

const base_size = Vector2(32, 32)

@onready var tRect = %TextureRect


func icon_update() -> void:
	%TextureRect.custom_minimum_size = base_size
	%TextureRect.size = base_size
	#%TextureRect.texture = element.texture
	%TextureRect.modulate = Global.color.element[element]
	%TextureRect.texture = load("res://asset/png/orb/" + element + ".png")
	pass
	
func move_to_slot_position(delay_: float) -> void:
	if true:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", slot.position, delay_).set_ease(Tween.EASE_OUT)
	
func smash() -> void:
	slot.proprietor.orbs.remove_child(self)
	slot.proprietor.presences[element].erase(self)
	queue_free()
