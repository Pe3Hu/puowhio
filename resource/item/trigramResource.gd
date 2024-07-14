class_name TrigramResource extends ItemResource


@export_enum("0", "1", "2", "3", "4", "5", "6", "7") var subtype: String = "0":
	set(subtype_):
		subtype = subtype_
	get:
		return subtype
