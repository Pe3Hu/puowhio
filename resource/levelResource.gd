class_name LevelResource extends Resource


@export var value: int:
	set(value_):
		value = value_
		
		strength.update_limit()
		dexterity.update_limit()
		intellect.update_limit()
		will.update_limit()
	get:
		return value
@export var strength: CoreResource
@export var dexterity: CoreResource
@export var intellect: CoreResource
@export var will: CoreResource


func _init() -> void:
	var aspects = ["strength", "dexterity", "intellect", "will"]
	
	for aspect in aspects:
		set(aspect, CoreResource.new())
		var core = get(aspect)
		core.aspect = aspect
		core.level = self
