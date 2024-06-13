extends VBoxContainer
var fx_path = "res://addons/audio_mixer_control/effects/"
var effects : Array[AudioEffect]
var bus : Mixer.Bus

func _ready():
	bus = owner.bus
	dir_contents(fx_path)
	build_list()
	%add_effect.get_popup().connect("index_pressed", add_effect)
	
func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			file_name = dir.get_next()
			var instance = fx_path + file_name
			if file_name.ends_with(".tres"):
				var effect = load(instance)
				if effect is AudioEffect:
					effects.append(effect)

func build_list():
	for effect in effects:
		%add_effect.get_popup().add_item(str(effect.get_class().replace("AudioEffect","")))

func add_effect(effect_index):
	var fx = effects[effect_index].duplicate()
	fx.resource_name = fx.get_class().replace("AudioEffect","")
	bus.add_effect(fx)
	
	var control_fx = load("res://addons/audio_mixer_control/effect/effect_control.tscn").instantiate()
	control_fx.bus = bus
	control_fx.effect = fx
	var count = 0; for node in %effects.get_children(): 
		if node is AudioEffectControl: 
			control_fx.effect_index = count
			count += 1
	add_child(control_fx)
