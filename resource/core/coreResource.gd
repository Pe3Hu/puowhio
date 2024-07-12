@tool
class_name CoreResource extends Resource


@export_enum("dexterity", "intellect", "strength", "will") var aspect: String = "dexterity":
	set(aspect_):
		aspect = aspect_
	get:
		return aspect

@export var level: int = 1:
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
		
			if current > limit:
				level += 1
				limit = pow(3 + level, 2)
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
