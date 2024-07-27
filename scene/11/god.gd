class_name God extends PanelContainer


@export var heaven: Heaven
@export var territory: Territory
@export var temple: Temple

@onready var mage_scene = preload("res://scene/1/mage.tscn")

var mages: Array[Mage]


func birth():
	visible = true
	
	for _i in 1:
		add_mage()
	
func add_mage() -> void:
	var mage = mage_scene.instantiate()
	mage.god = self
	temple.mages.add_child(mage)
	mage.inventory.roll_starter_items()
	mage.library.roll_starter_items()
	mage.init_threats()
	mage.reset()
	mage.is_temple = true
	mage.set_threat("offensive", 20)
	mage.set_threat("defensive", 20)
