class_name LevelResource extends Resource


const aspects = ["strength", "dexterity", "intellect", "will"]

@export var modifier: CounterResource
@export var experience: CounterResource
@export var strength: CoreResource
@export var dexterity: CoreResource
@export var intellect: CoreResource
@export var will: CoreResource


func _init() -> void:
	experience = CounterResource.new()
	experience.type = "limit"
	experience.limit = 20
	modifier = CounterResource.new()
	modifier.type = "modifier"
	
	for aspect in aspects:
		set(aspect, CoreResource.new())
		var core = get(aspect)
		core.aspect = aspect
		core.level = self
		core.modifier = CounterResource.new()
		core.modifier.type = "modifier"
		core.modifier.limit = 16
		core.modifier.current = 9
		core.experience = CounterResource.new()
		core.experience.type = "limit"
		core.experience.is_barriered = false
	
	update_core_counters()
	
func update_core_counters() -> void:
	modifier.limit = 0
	
	for aspect in aspects:
		var core = get(aspect)
		core.update_counters()
