@tool
class_name Bowl extends PanelContainer


@export var minion: Minion
@export var bar: Bar
@export var resource: BowlResource
@export var trigger: Sprite2D
@export var status: Sprite2D

@onready var buff_image = preload("res://asset/png/status/buff.png")
@onready var debuff_image = preload("res://asset/png/status/debuff.png")
@onready var overtime_image = preload("res://asset/png/status/overtime.png")


func init_resource() -> void:
	bar.fullness.fill_mode = 3#FillMode.FILL_BOTTOM_TO_TOP
	resource = BowlResource.new()
	
	match minion.type:
		"monster":
			var description = Global.dict.monster.title[minion.summary.kind].bowl
			
			resource.measure = description.measure
			resource.trigger = description.trigger
			resource.side = description.side
	
	init_hue()
	update_trigger_sprite()
	bar.value = 0
	
func init_hue() -> void:
	var hues = {}
	hues["wound"] = 335.0 / 360
	hues["critical"] = 40.0 / 360
	hues["dodge"] = 135.0 / 360
	hues["heal"] = 225.0 / 360
	var _trigger = Global.dict.monster.title[minion.summary.kind].bowl.trigger
	
	var saturations = {}
	saturations["under"] = 0.6
	saturations["progress"] = 0.85
	
	var values = {}
	values["under"] = 1.0
	values["progress"] = 0.75
	
	for key in saturations:
		var color = Color.from_hsv(hues[_trigger], saturations[key], values[key])
		bar.set("color_" + key, color)
	
func update_trigger_sprite() -> void:
	var description = Global.dict.monster.title[minion.summary.kind]
	trigger.frame = Global.arr.trigger.find(description.bowl.trigger)
	trigger.modulate = Global.color.side[description.bowl.side]
	bar.type = description.bowl.measure
	
	for _status in Global.arr.status:
		if Global.arr[_status].has(description.status):
			status.texture = get(_status + "_image")
			status.vframes = Global.arr[_status].size()
			status.frame = Global.arr[_status].find(description.status)
			pass
