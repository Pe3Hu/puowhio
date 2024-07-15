class_name EquilibriumResource extends Resource


@export var aqua: int = 0
@export var wind: int = 0
@export var fire: int = 0
@export var earth: int = 0
@export var ice: int = 0
@export var storm: int = 0
@export var lava: int = 0
@export var nature: int = 0

@export var inputs: Array[String]
@export var outputs: Array[String]


func change(element_: String, value_: int) -> void:
	set(element_,  get(element_) + value_)
	
	if get(element_) > 0:
		if outputs.has(element_):
			outputs.erase(element_)
		if !inputs.has(element_):
			inputs.append(element_)
	
	if get(element_) < 0:
		if inputs.has(element_):
			inputs.erase(element_)
		if !outputs.has(element_):
			outputs.append(element_)
	
	if get(element_) == 0:
		if outputs.has(element_):
			outputs.erase(element_)
		if inputs.has(element_):
			inputs.erase(element_)
	
func is_equal(equlibrium_: EquilibriumResource) -> bool:
	for element in inputs:
		if equlibrium_.get(element) != get(element):
			return false
	
	for element in outputs:
		if equlibrium_.get(element) != get(element):
			return false
	
	return true
	
func merge(equlibrium_: EquilibriumResource) -> void:
	for element in inputs:
		var value = equlibrium_.get(element)
		
		change(element, value)
	
	for element in outputs:
		var value = equlibrium_.get(element)
		
		change(element, value)
