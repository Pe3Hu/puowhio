@tool
class_name Status extends PanelContainer


@export var aura: Aura
@export var sprite: Sprite2D
@export var stack: Label
@export var is_stack: bool:
	set(is_stack_):
		is_stack = is_stack_
		stack.visible = is_stack
		
		if is_stack:
			sprite.scale = Vector2.ONE * 0.5
			sprite.position = Vector2.ONE * 16
		else:
			sprite.scale = Vector2.ONE * 0.625
			sprite.position = Vector2.ONE * 20
	get:
		return is_stack

var resource: StatusResource:
	set(resource_):
		resource = resource_
		is_stack = is_stack
		
		update_spite()
		update_label()
	get:
		return resource

@onready var buff_image = preload("res://asset/png/status/buff.png")
@onready var debuff_image = preload("res://asset/png/status/debuff.png")
@onready var overtime_image = preload("res://asset/png/status/overtime.png")


func update_spite() -> void:
	for _status in Global.arr.status:
		if Global.arr[_status].has(resource.type):
			sprite.texture = get(_status + "_image")
			sprite.vframes = Global.arr[_status].size()
			sprite.frame = Global.arr[_status].find(resource.type)
			pass
	
func update_label() -> void:
	stack.text = str(resource.stack_value)
