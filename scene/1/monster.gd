@tool
class_name Monster extends Minion


@export var summary: SummaryResource
@export var terrain: String:
	set(terrain_):
		terrain = terrain_
	get:
		return terrain
@export var bowl: Bowl

func _ready() -> void:
	summary = SummaryResource.new()
	
func roll_kind() -> void:
	if is_node_ready():
		var options = Global.dict.monster.terrain[terrain]
		summary.rarity = "common"
		summary.kind = options.back()#options.pick_random()
		%Kind.text = summary.kind.capitalize()
		roll_aspects()
	
func roll_aspects() -> void:
	var extremes = Global.dict.rarity.title[summary.rarity].aspect
	summary.aspects = Global.get_random_segment_point(extremes) * 0.01 * statistic.level.limit
	
	var weights = {}
	
	for aspect in Global.arr.aspect:
		var core = statistic.level.get(aspect)
		weights[core] = 1
		
		if summary.primary.subtype == aspect:
			weights[core] = summary.primary.value
		if summary.secondary.subtype == aspect:
			weights[core] = summary.secondary.value
	
	var counter = int(summary.aspects)
	
	while counter > 0:
		var core = Global.get_random_key(weights)
		Global.rng.randomize()
		var value = Global.rng.randi_range(1, max(counter / 4, 1))
		value = min(value, core.limit - core.current)
		counter -= value
		core.current += value
		
		if core.current == core.limit:
			weights.erase(core)
		
	statistic.recalc_doublet_values()
