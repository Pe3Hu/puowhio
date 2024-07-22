class_name StatusResource extends Resource


@export var type: String
@export var stack_value: int
@export var stack_step: int
@export var power: int = 30


func get_stacked_copy(step_: int) -> StatusResource:
	var copy = duplicate()
	#var copy = StatusResource.new()
	#copy.type = type
	#copy.stack_value = stack_value
	#copy.stack_step = stack_step
	#copy.power = power
	
	if step_ > 0:
		copy.stack_value += step_ * stack_step
	
	return copy
	
func merge(resource_: StatusResource) -> StatusResource:
	var copy = duplicate()
	copy.stack_value += resource_.stack_value
	return copy
