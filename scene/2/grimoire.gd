class_name Grimoire extends PanelContainer


@export var mage: Mage

func _ready():
	roll_scrolls()


func roll_scrolls() -> void:
	for scroll in %Scrolls.get_children():
		scroll.roll_shares()
