class_name ListResource extends Resource


@export var analogs: Array[ScrollResource]
@export var equilibrium: EquilibriumResource:
	set(equilibrium_):
		equilibrium = equilibrium_
	get:
		return equilibrium

@export var best_avg: int


func calc_avg() -> void:
	analogs.sort_custom(func(a, b): return a.avg > b.avg)
	best_avg = analogs[0].avg
	
func get_best_scroll_resource() -> ScrollResource:
	analogs.sort_custom(func(a, b): return a.avg > b.avg)
	var options = []
	
	for resource in analogs:
		if resource.avg < best_avg:
			break
		else:
			options.append(resource)
	
	return options.pick_random()
