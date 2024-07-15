class_name BookResource extends Resource


@export var lists: Array[ListResource]
@export var equilibriums: Array[EquilibriumResource]
@export var cycle: Array[EquilibriumResource]

@export var is_cycled = false


func calc_cycle() -> void:
	if lists.is_empty():
		pass
	var counter = 0
	is_cycled = false
	cycle.clear()
	
	var list = lists[0]
	cycle.append(list.equilibrium)
	
	while is_cycled and counter < 100:
		counter += 1
		
		print(list)
