extends Panel 
var bus : Mixer.Bus

## when there are NO effects index is -1, first effect index is 0
var total_effects = -1 
signal bus_index_changed

func _ready():
	
	%index.text = str(bus.index)
	
	%routing.bus = bus
	%effects.bus = bus
	if bus.bus_name != "":
		name = bus.bus_name
	else:
		bus.bus_name = AudioServer.get_bus_name(bus.index)
	# cannot remove master control bus.
	if bus.index == 0:
		%remove_bus.queue_free()
	
	%name.text = bus.bus_name
	update_fx()

func update_fx():
	for fx in AudioServer.get_bus_effect_count(bus.index):
		var control = load("res://addons/audio_mixer_control/effect/effect_control.tscn").instantiate()
		control.bus = bus
		control.effect = AudioServer.get_bus_effect(bus.index, fx)
		control.effect_index = fx
		#control.name = str(control.effect.get_class())
		%effects.add_child(control)
	
	
func _on_volume_value_changed(value):
	bus.volume_changed(value)

func _on_remove_bus_pressed():
	Mixer.remove_bus(bus.index)
	queue_free()

func _exit_tree():
	Mixer.sort_buses()
	bus_index_changed.emit()

func _on_select_effect_child_entered_tree(node):
	total_effects += 1
	if node is AudioEffectControl:
		node.effect_index = total_effects

func _on_select_effect_child_exiting_tree(node):
	total_effects -= 1
	#sort_effect_indexes()
	
func sort_effect_indexes():
	var fx_count = 0
	for child in %effects.get_children():
		if child is AudioEffectControl:
			fx_count += 1
			child.effect_index = fx_count


func _on_mute_toggled(toggled):
	bus.mute_toggled(toggled)

func _on_bypass_toggled(toggled):
	bus.bypass_toggled(toggled)

func _on_solo_toggled(toggled):
	bus.solo_toggled(toggled)

func _on_name_text_changed(new_text):
	bus.rename_bus(new_text)


func _on_resized():
	if size.x < 80 or size.y < 300:
		pop_in()
	else:
		pop_out()

func pop_in():
	%controls.hide()
	%volume.hide()
	%effect_selection.hide()
	
func pop_out():
	%controls.show()
	%volume.show()
	%effect_selection.show()
