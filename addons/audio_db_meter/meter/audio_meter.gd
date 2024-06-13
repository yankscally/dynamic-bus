extends HBoxContainer

var bus : Mixer.Bus
#TODO init bus
var finished_building = false

func build_meter(channel : String):
	var db_meter = TextureProgressBar.new()
	db_meter.max_value = 6
	db_meter.min_value = -80
	db_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	db_meter.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP
	db_meter.nine_patch_stretch = true
	db_meter.texture_progress = load("res://addons/audio_db_meter/meter/volume.tres")
	if channel == "L":
		db_meter.name = "L"
	else:
		db_meter.name = "R"
	add_child(db_meter)
	db_meter.unique_name_in_owner = true
	db_meter.owner = self
	
func _ready():
	bus = owner.bus
	build_meter("L")
	build_meter("R")
	finished_building = true
	
func _process(delta):
	if finished_building:
		var dB_l = AudioServer.get_bus_peak_volume_left_db(bus.index, 0)
		var dB_r = AudioServer.get_bus_peak_volume_right_db(bus.index, 0)
		if dB_l > 5:
			get_node("L").modulate.r = 200.0
		else:
			get_node("L").modulate.r = 1.0
		
		if dB_r > 5:
			get_node("R").modulate.r = 200.0
		else:
			get_node("R").modulate.r = 1.0
		
			
			
		get_node("L").value = dB_l
		get_node("R").value = dB_r
	#
