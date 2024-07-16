class_name ClassResource extends Resource


@export_enum(
	"healer", "poisoner", "breakwater", 
	"shadow", "destroyer", "illusionist", 
	"berserker", "arsonist", "reaper", 
	"keeper", "fortress", "undertaker" 
	) var title: String
@export_enum("volume", "counter", "no") var condition: String = "no"
@export_enum(
	"turn start", "turn end", 
	"damage done", "damage taken",
	"heal done", "damage blocked"
	) var trigger: String
@export_enum(
	"second breath", "fade", "curse", 
	"swap stance", "extra move"
	) var effect: String
@export_enum(
	"critical chance", "evasion chance",
	"damage multiplier", "armor multiplier",
	"damage modifier", "armor modifier"
	) var on_self: String
@export_enum(
	"critical chance", "accuracy chance",
	"damage multiplier", "armor multiplier"
	) var on_enemy: String
@export var effect_value: float
@export var effect_step: float = 0.0
@export var condition_value: int = 100
