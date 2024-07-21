class_name BookResource extends Resource


@export var lists: Array[ListResource]
@export var equilibrium: EquilibriumResource
@export var lists_cycle: Array[ListResource]
@export var equilibriums_cycle: Array[EquilibriumResource]

@export var is_cycled = false
@export var reissues: Array[ListResource]
@export var cycle_avg: int
@export var balance: int


func calc_cycle() -> void:
	if lists.is_empty():
		pass
	
	var counter = 0
	is_cycled = false
	equilibriums_cycle.clear()
	lists_cycle.clear()
	
	equilibrium = EquilibriumResource.new()
	cycle_avg = 0
	
	while !is_cycled and counter < 100:
		counter += 1
		
		var list = get_match_up()
		equilibrium.merge(list.equilibrium)
	
		var next_equilibrium = EquilibriumResource.new()
		next_equilibrium.merge(equilibrium)
		
		equilibriums_cycle.append(next_equilibrium)
		lists_cycle.append(list)
		cycle_avg += list.best_avg
	
		if lists.size() == 1:
			is_cycled = true
		
		if equilibrium.inputs.size() == 0 and equilibrium.outputs.size() == 0:
			is_cycled = true
		
		if equilibrium.is_overlimit():
			is_cycled = true
		
		var previous_equilibrium = equilibriums_cycle[equilibriums_cycle.size() - 2]
		
		if next_equilibrium.is_negative(previous_equilibrium):
			is_cycled = true
		
		#for output in equilibrium.outputs:
		#	print([counter, equilibrium.get(output)])
	
	balance = 0
	
	for output in equilibrium.outputs:
		balance += equilibrium.get(output)
	
	for input in equilibrium.inputs:
		balance -= equilibrium.get(input)
	
	cycle_avg = round(float(cycle_avg) / lists_cycle.size())
	var orbs = []
	
	for list in lists_cycle:
		for output in list.equilibrium.outputs:
			var _str = str(balance) + "+" + output
			orbs.append(_str)
		
		for input in list.equilibrium.inputs:
			var _str = str(balance) + "-" + input
			orbs.append(_str)
	
	#print(lists.size(), orbs, avg)
	
func get_match_up() -> ListResource:
	for _i in range(lists.size() - 1, -1, -1):
		var list = lists[_i]
		
		if equilibrium.is_passes_requirements(list.equilibrium):
			return list
	
	return ListResource.new()
	
func is_incomplete(grimoire_: Grimoire) -> bool:
	if equilibriums_cycle.back().is_empty():
		return false
		
	reissues.clear()
	
	for list in grimoire_.lists:
		if !lists.has(list):
			if list.equilibrium.inputs.size() > 0:
				if equilibriums_cycle.back().is_passes_requirements(list.equilibrium):
					if !is_repetition(list.equilibrium):
						reissues.append(list)
	
	return reissues.size() > 0
	
func is_repetition(equilibrium_: EquilibriumResource)  -> bool:
	for list in lists:
		if list.equilibrium.is_equal_inputs(equilibrium_):
			return true
	
	return false
	
#func is_repetition_old(equilibrium_: EquilibriumResource)  -> bool:
	#var new_equilibrium = EquilibriumResource.new()
	#new_equilibrium.merge(equilibrium_)
	#new_equilibrium.merge(equilibriums_cycle.back())
	#
	#
	#for _equilibrium in equilibriums_cycle:
		#if new_equilibrium.is_equal(_equilibrium):
			#if new_equilibrium.is_empty():
				#pass
			#return true
	#
	#return false
