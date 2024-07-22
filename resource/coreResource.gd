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
@export var experience: CounterResource
@export var modifier: CounterResource


func update_counters() -> void:
	modifier.limit = pow(level.modifier.current + 3, 2)
	level.modifier.limit += modifier.limit - pow(level.modifier.current + 2, 2)
	
	if level.modifier.current % 3 == 0:
		experience.limit += 1
	
func change_experience(value_: int) -> void:
	var integer = floor((experience.current + value_) / experience.limit)
	var remainder = (experience.current + value_) % experience.limit
	modifier.current += integer
	experience.current = remainder
