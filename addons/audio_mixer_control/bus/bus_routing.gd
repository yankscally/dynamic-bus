class_name BusRoutingOption
extends OptionButton

var bus : Mixer.Bus


func _ready():
	if bus == null:
		bus = owner.bus
	
	if owner.name == "Master":
		add_item("Speakers")
		select(0)
		disabled = true
	else:
		connect("pressed", _on_pressed)
		get_popup().connect("index_pressed", route_selected)
		#select(0)
	
	create_selections()
	selected = AudioServer.get_bus_index(AudioServer.get_bus_send(bus.index))
	
	
func _on_pressed():
	create_selections()
	pass
#
func route_selected(index):
	bus.send_bus_index(index)

func create_selections():
	clear()
	for b in Mixer.buses:
		if b.index < bus.index:
			add_item(b.bus_name)
