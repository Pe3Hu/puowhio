
class_name ScrollResource extends ItemResource


#@export_group("Scrolls")
@export_enum("generator", "converter", "duplicator", "absorber") var subtype = "generator"

@export var aspects: Array[DoubletResource]
@export var equilibrium: EquilibriumResource = EquilibriumResource.new()

#@export_subgroup("Digits")
@export_range(0, 6, 1) var input_limit: int = 0
@export_range(0, 4, 1) var output_limit: int = 0
@export_range(0, 100, 1) var dispersion: int = 25
@export_range(100, 900, 1) var multiplier: int = 100

@export var tier: int = 0
@export var avg: = 0
@export var minimum: = 0
@export var maximum: = 0
#@export_group("")

const base_cell_size = Vector2(65, 20)
