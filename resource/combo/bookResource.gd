class_name BookResource extends Resource


@export var lists: Array[ListResource]
@export var equilibrium: EquilibriumResource
@export var cycle: Array[ListResource]

@export var is_cycled = false
@export var reissues: Array[ListResource]
@export var avg: int
@export var balance: int


func calc_cycle() -> void:
	if lists.is_empty():
		pass
	
	var counter = 0
	is_cycled = false
	cycle.clear()
	
	equilibrium = EquilibriumResource.new()
	avg = 0
	
	while !is_cycled and counter < 100:
		counter += 1
		#var next_equilibrium = EquilibriumResource.new()
		#next_equilibrium.merge(equilibrium)
		
		var list = get_match_up()
		equilibrium.merge(list.equilibrium)
		
		cycle.append(list)
		avg += list.best_avg
	
		if lists.size() == 1:
			is_cycled = true
		
		if equilibrium.inputs.size() == 0 and equilibrium.outputs.size() == 0:
			is_cycled = true
		
		if equilibrium.is_overlimit():
			is_cycled = true
	
	balance = 0
	
	for output in equilibrium.outputs:
		balance += equilibrium.get(output)
	
	for input in equilibrium.inputs:
		balance -= equilibrium.get(input)
	
	avg = round(float(avg) / cycle.size())
	var orbs = []
	
	for list in cycle:
		for output in list.equilibrium.outputs:
			var _str = str(balance) + "+" + output
			orbs.append(_str)
		
		for input in list.equilibrium.inputs:
			var _str = str(balance) + "-" + input
			orbs.append(_str)

	print(lists.size(), orbs, avg)
	
	if lists.size() > 2:
		pass
	
func get_match_up() -> ListResource:
	for _i in range(lists.size() - 1, -1, -1):
		var list = lists[_i]
		
		if equilibrium.is_passes_requirements(list.equilibrium):
			return list
	
	return ListResource.new()
	
func is_incomplete(grimoire_: Grimoire) -> bool:
	reissues.clear()
	
	for list in grimoire_.lists:
		if !lists.has(list):
			if list.equilibrium.inputs.size() > 0:
				if equilibrium.is_passes_requirements(list.equilibrium):
					reissues.append(list)
	
	return reissues.size() > 0
