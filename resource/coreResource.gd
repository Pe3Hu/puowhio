@tool
class_name CoreResource extends Resource


@export_enum("dexterity", "intellect", "strength", "will") var aspect: String = "dexterity":
	set(aspect_):
		aspect = aspect_
	get:
		return aspect
@export var level: LevelResource:
	set(level_):
		level = level_
	get:
		return level
@export var current: int = 9:
	set(current_):
		if is_barriered:
			current = clamp(current_, 0, limit)
			#current = current_
		else:
			current = current_
	get:
		return current
@export var limit: int = 16:
	set(limit_):
		limit = limit_
	get:
		return limit
@export var is_barriered: bool = true:
	set(is_barriered_):
		is_barriered = is_barriered_
	get:
		return is_barriered


func update_limit() -> void:
	limit = pow(level.value + 3, 2)
	level.limit += limit - pow(level.value + 2, 2)
