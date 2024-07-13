@tool
class_name Item extends PanelContainer


@export var slot: Slot

@export var description: Description:
	set(description_):
		description = description_
		description.item = self
	get:
		return description

@export var resource: ItemResource:
	set(resource_):
		resource = resource_
		
		if is_node_ready():
			refresh_icon()
		
			match resource.rarity:
				"common":
					%Icon.modulate = Color.from_hsv(0.0, 0.0, 0.68)
				"uncommon":
					%Icon.modulate = Color.from_hsv(145 / hue, 0.77, 0.68)
				"rare":
					%Icon.modulate = Color.from_hsv(203 / hue, 0.77, 0.68)
				"epic":
					%Icon.modulate = Color.from_hsv(282 / hue, 0.77, 0.68)
				"legendary":
					%Icon.modulate = Color.from_hsv(48 / hue, 0.77, 0.68)
	get:
		return resource

@export var is_description_visible: bool = false:
	set(is_description_visible_):
		is_description_visible = is_description_visible_
		
		if is_node_ready():
			%Description.visible = is_description_visible
	get:
		return is_description_visible

var draggable = false
var is_inside_dropable = false
var body_ref
var offset: Vector2
var initial_position: Vector2
var slots: Array[Slot]

const hue: float = 360.0

func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("rclick"):
			is_description_visible = !is_description_visible
		if Input.is_action_just_pressed("lclick"):
			if slots.is_empty():
				initial_position = global_position#global_position
			else:
				initial_position = slot.global_position
			
			offset = get_global_mouse_position() - global_position
			Global.flag.is_dragging = true
			
		if Input.is_action_pressed("lclick"):
			if %Selected.frame != 0:
				%Selected.frame = 0
		
			global_position = get_global_mouse_position() - Global.vec.size.slot / 2
		elif Input.is_action_just_released("lclick"):
			Global.flag.is_dragging = false
			var delay = 0.2
			
			if is_inside_dropable:
				move_to_nearest_slot(delay)
			else:
				move_to_initial_position(delay)
	
func _on_area_2d_body_entered(body):
	if body.is_in_group('dropable'):
		if check_type(body.get_parent()):
			is_inside_dropable = true
			body.get_parent().collision_shape.debug_color = Color.from_hsv(0.33, 0.6, 0.7, 0.42)
			slots.append(body.get_parent())
	
func _on_area_2d_body_exited(body):
	if body.is_in_group('dropable'):
		if check_type(body.get_parent()):
			body.get_parent().collision_shape.debug_color = Color(0, 0.6, 0.7, 0.42)
			slots.erase(body.get_parent())
			
			if slots.is_empty():
				is_inside_dropable = false
	
func _on_area_2d_mouse_entered():
	if not Global.flag.is_dragging:
		draggable = true
		%Selected.visible = true
		%Selected.frame = 1
	
func _on_area_2d_mouse_exited():
	if not Global.flag.is_dragging:
		draggable = false
		%Selected.visible = false
	
	if is_description_visible:
		is_description_visible = false
	
func move_to_nearest_slot(delay_: float) -> void:
	slots.sort_custom(func(a, b): return a.position.distance_to(position) < b.position.distance_to(position))
	
	recolor_debug_slots()
	slot = slots.front()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", slot.global_position, delay_).set_ease(Tween.EASE_OUT)
	initial_position = slot.global_position
	
func move_to_initial_position(delay_: float) -> void:
	var tween = get_tree().create_tween()
	initial_position = slot.global_position
	tween.tween_property(self, "global_position", initial_position, delay_).set_ease(Tween.EASE_OUT)
	recolor_debug_slots()
	
func check_type(slot_: Slot) -> bool:
	if slot_.type == "any":
		return true
	
	if resource.type != slot_.type:
		return false
	
	if resource.type == "trigram":
		if resource.subtype != slot_.subtype:
			return false
	
	return true
	
func refresh_icon() -> void:
	if resource.type == "trigram":
		%Icon.frame = int(resource.subtype)
	if resource.type == "nucleus":
		%Icon.frame = 8
	
func recolor_debug_slots() -> void:
	for _slot in slots:
		_slot.collision_shape.debug_color = Color(0, 0.6, 0.7, 0.42)
