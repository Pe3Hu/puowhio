@tool
class_name Bowl extends PanelContainer


signal bar_is_crowded

@export var minion: Minion
@export var bar: Bar
@export var status: Status
@export var resource: BowlResource
@export var trigger: Sprite2D
#@export var status: Sprite2D


func init_resource() -> void:
	bar.fullness.fill_mode = 3#FillMode.FILL_BOTTOM_TO_TOP
	resource = BowlResource.new()
	status.resource = StatusResource.new()
	
	match minion.type:
		"monster":
			var description = Global.dict.monster.title[minion.summary.kind]
			
			resource.measure = description.bowl.measure
			resource.trigger = description.bowl.trigger
			resource.side = description.bowl.side
			bar.type = "bowl"
			bar.subtype = description.bowl.measure
			
			status.resource.type  = description.status.type
			status.resource.stack_value  = description.status.value
			status.resource.stack_step  = description.status.step
	
	init_hue()
	update_trigger_sprite()
	bar.value = 0
	bar.tempo = "standard"
	
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
	#bar.subtype = description.bowl.measure
	
	status.update_spite()
	
func _on_bar_is_crowded():
	bar.value -= bar.limit
	minion.aura.add_status(self)
