@tool
class_name StateMachine extends LimboHSM


@export var minion: Minion

var active_scroll: Scroll


func _ready() -> void:
	#update_mode = LimboHSM.MANUAL
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_enter).call_on_exit(idle_exit)
	var searching_state = LimboState.new().named("searching").call_on_enter(searching_enter).call_on_exit(searching_exit)
	var consuming_state = LimboState.new().named("consuming").call_on_enter(consuming_enter).call_on_exit(consuming_exit)
	var creating_state = LimboState.new().named("creating").call_on_enter(creating_enter).call_on_exit(creating_exit)
	var inflicting_state = LimboState.new().named("inflicting").call_on_enter(inflicting_enter).call_on_exit(inflicting_exit)
	
	add_child(idle_state)
	add_child(searching_state)
	add_child(consuming_state)
	add_child(creating_state)
	add_child(inflicting_state)
	
	#add_transition(ANYSTATE, idle_state, &"idle_started")
	add_transition(ANYSTATE, searching_state, &"searching_started")
	add_transition(searching_state, consuming_state, &"searching_ended")
	add_transition(consuming_state, creating_state, &"consuming_ended")
	add_transition(creating_state, inflicting_state, &"creating_ended")
	add_transition(inflicting_state, idle_state, &"inflicting_ended")
	add_transition(ANYSTATE, idle_state, &"state_ended")
	
	initial_state = idle_state
	initialize(self)
	set_active(true)
	
func idle_enter() -> void:
	if minion.is_active:
		pass
		#state#print("idle")
	pass
	
func idle_exit() -> void:
	pass

func searching_enter() -> void:
	if minion.is_active:
		#state#print("searching")
		
		#for scroll in minion.grimoire.ordered_scrolls:
			#state#print(scroll.resource.equilibrium.get_dictionary())
		
		for scroll in minion.grimoire.ordered_scrolls:
			if minion.conveyor.check_orbs_availability(scroll):
				active_scroll = scroll
				#state#print("!", scroll.resource.equilibrium.get_dictionary())
				dispatch(&"searching_ended")
				return
		
		if active_scroll == null:
			return 
	
func searching_exit() -> void:
	pass
	
func consuming_enter() -> void:
	if minion.is_active:
		#state#print("consuming")
		
		for element in active_scroll.resource.equilibrium.inputs:
			for _i in abs(active_scroll.resource.equilibrium.get(element)):
				var orb = minion.conveyor.elements[element].back()
				orb.smash()
		
		dispatch(&"consuming_ended")
	
func consuming_exit() -> void:
	pass
	
func creating_enter() -> void:
	if minion.is_active:
		#state#print("creating")
		#var a = active_scroll.resource.output_orbs
		for element in active_scroll.resource.equilibrium.outputs:
			minion.conveyor.add_orb(element)
	
		dispatch(&"creating_ended")
	
func creating_exit() -> void:
	pass
	
func inflicting_enter() -> void:
	if minion.is_active:
		#state#print("inflicting")
		#Global.rng.randomize()
		#var daminion = Global.rng.randi_range(active_scroll.resource.minimum, active_scroll.resource.maximum)
		var impulse = ImpulseResource.new()
		impulse.base = Global.get_random_segment_point(active_scroll.resource)
		#impulse.type = "damage"
		minion.battle.observer.apply_impulse(impulse)
		
		dispatch(&"inflicting_ended")
	
func inflicting_exit() -> void:
	active_scroll = null
	minion.call_pass()
	minion.is_active = false
