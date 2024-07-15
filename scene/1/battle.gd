@tool
class_name Battle extends PanelContainer


@export var world: World

@export var current_mage: Mage

@export var turn: int = 0

@onready var mages = %Mages

func _ready() -> void:
	await get_tree().process_frame
	current_mage.reset()
	#current_mage.start_turn()
