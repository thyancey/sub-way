@tool
extends Control

@export var label_name = "???":
	get:
		return label_name
	set(value):
		if (value != label_name):
			label_name = value
			_render_name()

@export var label_value = "???":
	get:
		return label_value
	set(value):
		if (value != label_value):
			label_value = value
			_render_value()

func _ready() -> void:
	_render_name()
	_render_value()

func _render_name() -> void:
	%Name.text = label_name + ':'
	
func _render_value() -> void:
	%Value.text = label_value
