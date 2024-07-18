@tool
class_name Monster extends Minion


@export var summary: SummaryResource
@export var terrain: String:
	set(terrain_):
		terrain = terrain_
		
		roll_kind()
	get:
		return terrain


func _ready() -> void:
	summary = SummaryResource.new()
	
func roll_kind() -> void:
	if is_node_ready():
		var options = Global.dict.monster.terrain[terrain]
		summary.kind = options.back()#options.pick_random()
		%Kind.text = summary.kind.capitalize()
