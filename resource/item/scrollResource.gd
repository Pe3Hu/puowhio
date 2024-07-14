class_name ScrollResource extends ItemResource


@export_enum("generator", "converter", "duplicator", "absorber") var subtype = "generator"

@export_range(0, 6, 1) var input_limit: int = 0
@export_range(0, 4, 1) var output_limit: int = 0

@export var aspects: Array[DoubletResource]
@export var input_orbs: Array[String]
@export var output_orbs: Array[String]

@export_range(0, 100, 1) var dispersion: int = 25
@export_range(100, 900, 1) var multiplier: int = 100

@export var tier: int = 0

@export var demands: Dictionary

var avg: = 0
var minimum: = 0
var maximum: = 0

const base_cell_size = Vector2(65, 20)
