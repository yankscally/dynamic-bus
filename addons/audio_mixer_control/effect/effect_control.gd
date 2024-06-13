extends VBoxContainer
class_name AudioEffectControl

var effect : AudioEffect
var text : String
var bus : Mixer.Bus
var effect_index : int

var finished_building = false

#func _init():
	#

func _ready():
	
	%effect.text = str(effect.get_class())
	

	

	
#func _on_active_toggled(toggled_on):
	#if toggled_on:
		#AudioServer.set_bus_effect_enabled(bus_index, effect_index, toggled_on)
	#else:
		#AudioServer.set_bus_effect_enabled(bus_index, effect_index, toggled_on)


func _on_effect_toggled(toggled_on):
	if toggled_on:
		if finished_building == true:
			for child in get_children(): child.show()
		else:
			for parameter in effect.get_property_list():
				#print(parameter)
				if parameter.get("type") == 1:
					var checkbox_panel = HBoxContainer.new()
					checkbox_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					
					var p_label = Label.new()
					var p_name = parameter.get("name")
					p_label.text = p_name
					checkbox_panel.add_child(p_label)
					
					var checkbox = CheckBox.new()
					checkbox.connect("toggled", on_effect_toggle_changed.bind(parameter.get("name"))) 
					checkbox_panel.add_child(checkbox)
					add_child(checkbox_panel)
					
				if parameter.get("type") == 3:
					var slider_panel = HBoxContainer.new()
					slider_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					
					var p_label = Label.new()
					var p_name = parameter.get("name")
					p_label.text = p_name
					slider_panel.add_child(p_label)
					
					var range_control : Range
					
					var new_range = parameter.get("hint_string")
					var range = new_range.split(",")

					range_control = HSlider.new()
					range_control.min_value = int(range[0])
					range_control.max_value = int(range[1])
					range_control.step = int(range[2])
						
					range_control.connect("value_changed", on_effect_parameter_changed.bind(parameter.get("name"))) 
					#effect.connect("changed", effect_changed)
					
					range_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					slider_panel.add_child(range_control)
					
					add_child(slider_panel)
					
			finished_building = true
	else:
		if finished_building:
			for child in get_children(): if child.name != "control_panel": child.hide()


func on_effect_parameter_changed(value, parameter):
	print(parameter, effect_index)
	var fx = AudioServer.get_bus_effect(bus.index, effect_index-1)
	fx.set(parameter, value)


func on_effect_toggle_changed(value, parameter):
	var fx = AudioServer.get_bus_effect(bus.index, effect_index-1)
	fx.set(parameter, value)

func _on_remove_pressed():
	Mixer.buses[bus.index].remove_effect(effect_index-1)
	queue_free()
