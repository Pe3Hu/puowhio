class_name Record extends PanelContainer


@export var first: Label
@export var second: Label

const max_size = Vector2(175, 25)


func set_label_text(order_: String, text_: String) -> void:
	var label = get(order_)
	label.text = str(text_)
