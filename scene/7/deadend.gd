class_name Deadend extends Node2D


@export_enum("earldom", "dukedom", "kingdom", "empire") var layer: = "earldom":
	set(layer_):
		layer = layer_
	get:
		return layer

@export var map: Map
@export var root: Domain
@export var chain: Array[Domain]
#@export var domains: Array[Domain]


func _ready() -> void:
	for fiefdom in root.fiefdoms:
		fiefdom.color = Color.BLACK
