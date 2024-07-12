@tool
class_name Scroll extends PanelContainer


@export var grimoire: Grimoire

@export var resource: ScrollResource:
	set(resource_):
		resource = resource_
		
		if is_node_ready():
			%Primary.resource.icon_name = resource.primary_aspect
			%Secondary.resource.icon_name = resource.secondary_aspect
	get:
		return resource

@export var cell_size: Vector2 = base_cell_size:
	set(cell_size_):
		cell_size = cell_size_
		
		if is_node_ready():
			%Damage.custom_minimum_size = cell_size
			%Damage.size = cell_size
	get:
		return cell_size

@export var refreshed: bool = false:
	set(refreshed_):
		refreshed = refreshed_
		
		if is_node_ready():
			primary_share = primary_share
			resource = resource
			%Primary.resource = %Primary.resource
			%Secondary.resource = %Secondary.resource
	get:
		return refreshed

@export var input_orbs: Array[OrbResource]
@export var output_orbs: Array[OrbResource]

@export_range(50, 100, 1) var primary_share: int = 80:
	set(primary_share_):
		primary_share = primary_share_
		
		if is_node_ready():
			%Primary.value = primary_share
		
		secondary_share = 100 - primary_share
	get:
		return primary_share

@export_range(0, 50, 1) var secondary_share: int = 20:
	set(secondary_share_):
		secondary_share = secondary_share_
		
		if is_node_ready():
			%Secondary.value = secondary_share
	get:
		return secondary_share

@export_range(0, 100, 1) var dispersion: int = 25
@export_range(100, 900, 1) var multiplier: int = 100

@export var avg: float = 0:
	set(avg_):
		avg = avg_
		
		minimum = floor(avg * (1 - float(dispersion) / 100) * multiplier / 100)
		maximum = floor(avg * (1 + float(dispersion) / 100) * multiplier / 100)
		
		if is_node_ready():
			%Damage.text = str(minimum) + " - " + str(maximum)
	get:
		return avg

var minimum: = 0
var maximum: = 0

const base_cell_size = Vector2(65, 20)


func _ready() -> void:
	refreshed = !refreshed
	
	for doublet in %Aspects.get_children():
		doublet.recolor(true)
	
	calc_avg()
	
func roll_shares() -> void:
	pass 
	
func calc_avg() -> void:
	var _avg = 0
	#var values = []
	var keys = ["primary", "secondary"]
	
	for key in keys:
		var type = resource.get(key + "_aspect")
		var doublet = grimoire.mage.statistic.get(type)
		var share = float(get(key + "_share")) / 100
		_avg += doublet.value * share
		#values.append(doublet.value * share)
	
	avg = _avg
