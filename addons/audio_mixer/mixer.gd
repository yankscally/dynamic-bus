## Mixer
# autoload for dynamic audio and debugging the bus system in real time.
extends Node
var input = AudioServer.get_input_device_list()
var output = AudioServer.get_output_device_list()

var buses : Array[Bus]


func instance_bus(bus : Bus):
	owner
	AudioServer.add_bus(bus.index)
	buses.insert(bus.index, bus)

func insert_bus(bus_position):
	AudioServer.add_bus(bus_position)
	var bus = Bus.new()
	bus.index = bus_position
	buses.append(bus)
	return bus

func _init():
	AudioServer.bus_layout_changed.connect(layout_changed)
	AudioServer.bus_renamed.connect(bus_renamed)
	add_master_bus()

func _ready():
	for bus in AudioServer.bus_count:
		if bus == 0:
			pass
		else:
			var new_bus = Bus.new()
			new_bus.index = bus
			new_bus.bus_name = AudioServer.get_bus_name(bus)
			new_bus.send = AudioServer.get_bus_name(bus)
			new_bus.persistent = true
			buses.append(new_bus)

func get_send(index):
	return AudioServer.get_bus_send(index)
	

#
func populate_buses():
	for bus in AudioServer.bus_count:
		var new_bus = add_bus()
		new_bus.index = bus
		new_bus.bus_name = AudioServer.get_bus_name(bus)
		new_bus.persistent = true
		
		
func layout_changed():
	pass
		
		
func bus_renamed():
	pass

func add_master_bus():
	var master_bus = Bus.new()
	master_bus.bus_name = "Master"
	master_bus.index = 0
	buses.append(master_bus)

func add_bus():
	AudioServer.add_bus(AudioServer.bus_count)
	#AudioServer.set_bus_name(AudioServer.bus_count, "")
	
	var bus = Bus.new()
	bus.index = buses.size()
	
	buses.append(bus)
	return bus


	
func remove_bus(bus_position):
	AudioServer.remove_bus(bus_position)
	buses.remove_at(bus_position)

# to be used when a random bus is removed, causing Bus.index to be incorrect...
func sort_buses():
	var count = 0
	for bus in buses:
		bus.index = count
		bus.bus_name = AudioServer.get_bus_name(bus.index)
		count += 1

func save_layout(path):
	var layout = AudioServer.generate_bus_layout()
	ResourceSaver.save(layout, path)

func load_layout(path):
	var layout = load(path)
	AudioServer.set_bus_layout(layout)

func get_layout_routing():
	var list = []
	for bus in AudioServer.bus_count:
		list.append(AudioServer.get_bus_send(bus))
	return list

class Bus:
	## persistent buses are unable to be deleted
	var persistent = false
	
	## for now just a tag for degugging purposes
	var spatial = false
	
	var index : int # why???
	var bus_name : String
	var send := "Master" #StringName..
	var volume = 0 : set = volume_changed 
	var solo = false : set = solo_toggled
	var mute = false : set = mute_toggled
	var bypass = false : set = bypass_toggled
	var effects : Array[AudioEffect]
	
	func _init():
		index = AudioServer.bus_count-1
		bus_name = AudioServer.get_bus_name(index)

	func volume_changed(value):
		AudioServer.set_bus_volume_db(index, value)
		volume = value
		
	func move_bus(new_index):
		AudioServer.move_bus(index, new_index)
		index = new_index

	## WARNING: buses forget send when renamed
	func rename_bus(new_name):
		#for bus in Mixer.buses:
			#if bus.index < index:
				#if bus.send == bus_name:
					#bus.send = new_name
		var send_refs = []
		for bus in bus_name:
			bus
		
		AudioServer.set_bus_name(index, new_name)
		bus_name = new_name
		AudioServer.set_bus_send(index, get_send(index))
			
		
	func solo_toggled(toggled):
		AudioServer.set_bus_solo(index, toggled)
		solo = toggled
	func mute_toggled(toggled):
		AudioServer.set_bus_mute(index, toggled)
		mute = toggled
	func bypass_toggled(toggled):
		AudioServer.set_bus_bypass_effects(index, toggled)
		bypass = toggled
	
	func effect_toggled(toggled, effect_index):
		AudioServer.set_bus_effect_enabled(index, effect_index, toggled)
	
	func add_effect(effect : AudioEffect):
		AudioServer.add_bus_effect(index, effect) #,at position??
		effects.append(effect)
	
	func remove_effect(effect_index):
		AudioServer.remove_bus_effect(index, effect_index)
	
	func get_send(index):
		return AudioServer.get_bus_send(index)

	func set_send(bus_name):
		AudioServer.set_bus_send(index, bus_name)
		send = bus_name
		
	func send_bus_index(idx):
		AudioServer.set_bus_send(index, AudioServer.get_bus_name(idx))
		send = AudioServer.get_bus_send(idx)


	
