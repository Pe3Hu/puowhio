class_name Perimeter extends Node2D


@export var domain: Domain

var proximates: Array[Fiefdom]
var externals: Array[Fiefdom]
var internals: Array[Fiefdom]
var frontiers: Dictionary
var neighbors: Dictionary


func set_fiefdom_as_external(fiefdom_: Fiefdom) -> void:
	proximates.erase(fiefdom_)
	externals.append(fiefdom_)
	
	for neighbor in fiefdom_.neighbors:
		var neighbor_domain = neighbor.get(domain.layer)
		
		if neighbor_domain != domain:
			if !proximates.has(neighbor) and !domain.fiefdoms.has(neighbor):
				proximates.append(neighbor)
		elif neighbor_domain != null:
			set_fiefdom_as_internal(neighbor)
	
func set_fiefdom_as_internal(fiefdom_: Fiefdom) -> void:
	if !externals.has(fiefdom_):
		return
	
	for neighbor in fiefdom_.neighbors:
		if proximates.has(neighbor):
			return
	
	externals.erase(fiefdom_)
	internals.append(fiefdom_)
