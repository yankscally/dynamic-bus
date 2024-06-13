# control mixer
# a control node version to complement mixer.gd
# not needed for most projects, but useful for debugging and audio based projects.
extends Control

@onready var control_bus_scene = load("res://addons/audio_mixer_control/bus/bus_control.tscn")

@export var pop_in_on_start = false


var bus_naming : String

func _init():
	AudioServer.bus_layout_changed.connect(layout_changed)

func add_master_bus():
	var bus = Mixer.buses[0]
	var control_bus = add_control_bus()
	control_bus.name = bus.bus_name
	control_bus.bus = bus
	%buses.add_child(control_bus)

func add_control_bus():
	var control_bus = control_bus_scene.instantiate()
	return control_bus

func _on_add_bus_pressed():
	var bus = Mixer.add_bus()
	var control = add_control_bus()
	control.bus = bus
	%buses.add_child(control)
	
	if size.x < get_window().size.x - 50:
		size.x += 50
	
	
func layout_changed():
	pass
	#print("///")
	#for bus in Mixer.buses:
		#print(bus.bus_name)
		
func _ready():
	for bus in Mixer.buses:
		var new_control = add_control_bus()
		new_control.bus = bus
		new_control.name = bus.bus_name
		%buses.add_child(new_control)
	
	if pop_in_on_start:
		_on_pop_in_pressed()
func _on_save_layout_pressed():
	pass # Replace with function body.


func _on_bus_name_text_changed(new_text):
	bus_naming = new_text


func _on_pop_in_pressed():
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var total_buses = %buses.get_children().size()
	size.x = total_buses * 50 + 50

func _on_pop_out_pressed():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size.x = get_window().size.x
