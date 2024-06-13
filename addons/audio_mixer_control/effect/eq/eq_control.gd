extends Control

@export_enum("eq6", "eq10", "eq21") var eq_bands : int : set = set_eq
var eq : AudioEffectEQ
var sliders = []

func set_eq(value):
	#AudioServer.remove_bus_effect(0, 0)  # Remove any existing EQ effect
	if value == 0:
		eq = AudioEffectEQ6.new()
	elif value == 1:
		eq = AudioEffectEQ10.new()
	else:
		eq = AudioEffectEQ21.new()
	AudioServer.add_bus_effect(0, eq)
	AudioServer.add_bus_effect(0, AudioEffectSpectrumAnalyzer.new() , -1)
	_create_sliders()

func _create_sliders():
	for slider in sliders:
		remove_child(slider)
	sliders.clear()
	for i in range(eq.get_band_count()):
		var slider = VSlider.new()
		slider.min_value = -24
		slider.max_value = 24
		slider.value = eq.get_band_gain_db(i)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.connect("value_changed", _on_slider_value_changed.bind(i))
		add_child(slider)
		sliders.append(slider)

func _on_slider_value_changed(value, band_idx):
	var eq = AudioServer.get_bus_effect(0,0) as AudioEffectEQ
	eq.set_band_gain_db(band_idx, value)

const vu_count = 256
const freq_max = 22000.0
var width = 800
var height = 250
const height_scale = 8.0
const min_db = 60
const animation_speed = 0.1

var spectrum
var min_values = []
var max_values = []

func _draw():
	var w = width / vu_count
	for i in range(vu_count):
		var min_height = min_values[i]
		var max_height = max_values[i]
		var bar_height = lerp(min_height, max_height, animation_speed)
		var y_position = height - bar_height
		draw_rect(Rect2(w * i, y_position, w - 2, bar_height), Color.WHITE)
		draw_line(Vector2(w * i, y_position), Vector2(w * i + w - 2, y_position), Color.WHITE, 2.0, true)

func _process(_delta):
	var data = []
	var prev_hz = 0
	for i in range(1, vu_count + 1):
		var hz = i * freq_max / vu_count
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
		var bar_height = energy * height * height_scale
		data.append(bar_height)
		prev_hz = hz
	for i in range(vu_count):
		max_values[i] = max(data[i], lerp(max_values[i], data[i], animation_speed))
		min_values[i] = lerp(min_values[i], 0.0, animation_speed) if data[i] <= 0.0 else min_values[i]
	queue_redraw()

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0,1)
	min_values.resize(vu_count)
	max_values.resize(vu_count)
	min_values.fill(0.0)
	max_values.fill(0.0)

func _on_resized():
	width = size.x
	height = size.y
