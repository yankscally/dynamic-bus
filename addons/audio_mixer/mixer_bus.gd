# to be added as a child to mixer.gd a node representation of a single audio bus + effects
class_name MixerBus
extends Node

@export var bus_index : int #: set = move_bus
@export var bus_name := ""
@export var bus_routing := "Master"

@export var effects : Array[AudioEffect]

@export var solo = false
@export var mute = false
@export var bypass = false





