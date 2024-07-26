class_name Heaven extends PanelContainer


@export var world: World


var gods: Array[God]


func add_god(god_: God, fiefdom_: Fiefdom) -> void:
	gods.append(god_)
	god_.territory.capital = fiefdom_
	god_.heaven = self
	#god_.territory.recolor_fiefdoms()
