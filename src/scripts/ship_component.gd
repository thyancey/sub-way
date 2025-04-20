extends Node2D

class_name Ship_Component

@onready var graphic: Node2D = %Graphic
@export var display_name := "???"
@export var hide_on_disable := false
@export var is_active := false:
	get:
		return is_active
	set(value):
		if is_active != value:
			is_active = value
			_on_active_changed(is_active)

func _on_active_changed(_val: bool):
	# if _val:
	# 	modulate.a = 1.0
	# else:
	# 	modulate.a = 0.3

	if hide_on_disable:
		if _val:
			graphic.show()
		else:
			graphic.hide()

func _ready():
	_on_active_changed(is_active)
