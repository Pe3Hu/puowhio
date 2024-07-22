class_name CounterResource extends Resource


@export_enum("experience", "modifier") var type: String = "experience"

@export var current: int = 1:
	set(current_):
		if is_barriered:
			current = clamp(current_, 0, limit)
		else:
			current = current_
	get:
		return current
@export var limit: int = 1:
	set(limit_):
		limit = limit_
	get:
		return limit

@export var is_barriered: bool = true:
	set(is_barriered_):
		is_barriered = is_barriered_
	get:
		return is_barriered
