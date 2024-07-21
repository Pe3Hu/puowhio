class_name BowlResource extends Resource


@export_enum("sum", "count") var measure: String
@export_enum("done", "taken", "start", "end") var side: String
@export_enum("wound", "critical", "dodge", "heal", "block", "turn") var trigger: String


func is_equal(resource_: BowlResource) -> bool:
	for key in Global.arr.bowl:
		if get(key) != resource_.get(key):
			return false
	
	return true
