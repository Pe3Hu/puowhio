class_name ScrollResource extends Resource



@export_enum("generator", "converter", "duplicator", "absorber") var type = "generator"
@export_enum("strength", "dexterity", "intellect", "will") var primary_aspect = "strength"
@export_enum("strength", "dexterity", "intellect", "will") var secondary_aspect = "strength"

@export_range(0, 6, 1) var input_limit: int = 0
@export_range(0, 4, 1) var output_limit: int = 0
