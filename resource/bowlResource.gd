class_name BowlResource extends Resource


@export_enum("sum", "count") var measure: String
@export_enum("done", "taken") var side: String
@export_enum("wound", "critical", "dodge", "heal") var trigger: String
