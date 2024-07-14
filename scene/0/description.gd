class_name Description extends MenuBar


@export var item: Item

@export var cell_size: Vector2:
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
			pass
			#primary_share = primary_share
			#resource = resource
			#%Primary.resource = %Primary.resource
			#%Secondary.resource = %Secondary.resource
	get:
		return refreshed

@onready var doublet_scene = load("res://scene/0/doublet.tscn")
@onready var orb_scene = load("res://scene/4/orb.tscn")
@onready var damage = %Damage


func init_doublets() -> void:
	for resource in item.resource.bases:
		var doublet = doublet_scene.instantiate()
		doublet.set_from_base(resource)
		%Aspects.add_child(doublet)
	
	for resource in item.resource.affixs:
		var doublet = doublet_scene.instantiate()
		doublet.set_from_affix(resource)
		%Parameters.add_child(doublet)
	
	if item.resource.type == "scroll":
		for resource in item.resource.aspects:
			var doublet = doublet_scene.instantiate()
			doublet.set_from_doublet(resource)
			%Aspects.add_child(doublet)
		
		recolor()
	
func init_orbs() -> void:
	for element in item.resource.input_orbs:
		var orb = orb_scene.instantiate()
		orb.element = element
		%Inputs.add_child(orb)
		
		#orb.icon_update()
	
	for element in item.resource.output_orbs:
		var orb = orb_scene.instantiate()
		orb.element = element
		%Outputs.add_child(orb)
		#orb.icon_update()
	pass
	
func recolor() -> void:
	for doublet in %Aspects.get_children():
		doublet.recolor(true)
	
func calc_avg() -> void:
	item.resource.avg = 0
	
	for resource in item.resource.aspects:
		var doublet = item.slot.proprietor.mage.statistic.get(resource.subtype)
		var share = resource.value
		item.resource.avg += doublet.value * share * float(item.resource.multiplier) / 10000
	
	item.resource.minimum = floor(float(100 - item.resource.dispersion) / 100 * item.resource.avg)
	item.resource.maximum = floor(float(100 + item.resource.dispersion) / 100 * item.resource.avg)
	
	%Damage.text = str(item.resource.minimum) + " - " + str(item.resource.maximum)
