class_name ListResource extends Resource


@export var analogs: Array[ScrollResource]
@export var input_orbs: Array[String]
@export var output_orbs: Array[String]

@export var equilibrium: EquilibriumResource:
	set(equilibrium_):
		equilibrium = equilibrium_
	get:
		return equilibrium
