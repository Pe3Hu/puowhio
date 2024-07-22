@tool
class_name Observer extends PanelContainer


@export var battle: Battle
@export var active: Minion
@export var passive: Minion


#var resources: Array[BowlResource]
var bowls: Dictionary

const measures = [["sum", "count"], ["count"]]
const sides = [["done", "taken"], ["start", "end"]]
const triggers = [["wound", "critical", "dodge", "heal", "block"], ["turn"]]

var impulse: ImpulseResource
var extremes: Dictionary


func _ready() -> void:
	extremes.minimum = 0
	extremes.maximum = 100
	
	for _i in sides.size():
		for measure in measures[_i]:
			for side in sides[_i]:
				for trigger in triggers[_i]:
					var resource = BowlResource.new()
					resource.measure = measure
					resource.side = side
					resource.trigger = trigger
					
					#resources.append(resource)
					bowls[resource] = []
	 
func reset() -> void:
	for resource in bowls:
		bowls[resource] = []
	
	for minion in battle.initiatives:
		minion.declare_bowls()
	
	for _i in range(bowls.keys().size() -1, -1, -1):
		var resource = bowls.keys()[_i]
		
		if bowls[resource].is_empty():
			bowls.erase(resource)
	
	for resource in bowls:
		print(resource, bowls[resource])
	
func on_attack() -> void:
	pass
	
func apply_impulse(impulse_: ImpulseResource) -> void:
	impulse = impulse_
	
	match impulse.type:
		"damage":
			roll_accuracy()
			
			if !impulse.is_dodge:
				roll_evasion()
			
			if !impulse.is_dodge:
				impulse_.result = impulse_.base
				roll_critical()
				
				if impulse.is_crit:
					impulse_.result *= 1
				
				apply_reduction()
				passive.health.value -= impulse_.result
			
			if impulse.is_dodge:
				print("dodge!")
			else:
				if impulse.is_crit:
					print("crit!")
				else:
					print("wound ", impulse_.result)
			
			for resource in bowls:
				for bowl in bowls[resource]:
					if bowl.minion == active:
						if !impulse.is_dodge:
							if !impulse.is_crit:
								if bowl.resource.side == "done":
									if bowl.resource.trigger == "wound":
										var value = impulse_.result
										
										if bowl.resource.measure == "count":
											value = 1
										
										bowl.bar.value += value
	
func roll_accuracy() -> void:
	var roll = Global.get_random_segment_point(extremes)
	var separator = active.statistic.accuracy_chance.resource.value
	var type = "blindness"
	
	if active.aura.offensives.has(type):
		active.aura.change_stack(type, -1)
		var status = active.aura.types[type]
		separator -= status.resource.power
	
	impulse.is_dodge = roll > separator
	#print(["accuracy", roll, separator, impulse.is_dodge])
	
func roll_evasion() -> void:
	var roll = Global.get_random_segment_point(extremes)
	var separator = passive.statistic.evasion_chance.resource.value
	var type = "flexibility"
	
	if passive.aura.defensives.has(type):
		passive.aura.change_stack(type, -1)
		var status = active.aura.types[type]
		separator += status.resource.power
		
	impulse.is_dodge = roll < separator
	#print(["evasion", roll, separator, impulse.is_dodge])
	
func roll_critical() -> void:
	var roll = Global.get_random_segment_point(extremes)
	var separator = active.statistic.critical_chance.resource.value
	var type = "fortune"
	
	if active.aura.offensives.has(type):
		active.aura.change_stack(type, -1)
		var status = active.aura.types[type]
		separator += status.resource.power
	
	impulse.is_crit = roll < separator
	#print(["critical", roll, separator, impulse.is_crit])
	
func apply_reduction() -> void:
	var multiplier = 1.0
	var types = ["protection", "vulnerability"]
	
	for type in types:
		if passive.aura.defensives.has(type):
			var status = passive.aura.types[type]
			
			match type:
				"protection":
					multiplier += float(status.resource.power) / 100.0
				"vulnerability":
					multiplier -= float(status.resource.power) / 100.0
			
			passive.aura.change_stack(type, -1)
	
	impulse.reduction = float(passive.statistic.armor_multiplier.resource.value) / 100
	impulse.reduction *= impulse.result
	impulse.reduction += passive.statistic.armor_modifier.resource.value
	impulse.reduction = round(impulse.reduction * multiplier)
	impulse.result -= impulse.reduction
