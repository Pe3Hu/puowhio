@tool
class_name Bowl extends PanelContainer


@export_enum("standard", "instant") var tempo: String = "instant"

@export var resource: BowlResource
@export var proprietor: PanelContainer
@export var texture_size: Vector2 = Vector2(16, 16):
	set(texture_size_):
		texture_size = texture_size_
		
		if is_node_ready():
			%Fullness.custom_minimum_size = texture_size
			%Fullness.size = texture_size
	get:
		return texture_size

@export var color_under: Color = Color.WHITE:
	set(color_under_):
		color_under = color_under_
		%Fullness.tint_under = color_under
	get:
		return color_under
@export var color_progress: Color = Color.WHITE:
	set(color_progress_):
		color_progress = color_progress_
		%Fullness.tint_progress = color_progress
	get:
		return color_progress

@export var treatment_time: float = 0.5
@export var limit: int = 100:
	set(limit_):
		limit = limit_
		%Fullness.max_value = limit
		%Label.text = str(round(limit))
	get:
		return limit
@export var value: int = 0:
	set(value_):
		value = clamp(value_, 0, limit)
		
		if is_node_ready():
			var tween = create_tween().set_parallel()
			var modifier = get(tempo + "_modifier")
			var time = treatment_time * modifier
			#var points = type.capitalize()[0]+ "P "
			
			tween.tween_property(%Fullness, "value", value, time)
			tween.connect("finished", on_tween_finished)
	get:
		return value

@export var standard_modifier: float = 1.0
@export var instant_modifier: float = 0.0


func on_tween_finished() -> void:
	pass
	
func update_cavity_value() -> void:
	pass
