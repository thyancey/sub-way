@tool
extends Control

@export var value_range := Vector2(0.0, 100.0)
@export var decimals := 2

@export_range(-180, 0, 0.2) var rotation_min: float = -180.0
@export_range(-180, 0, 0.2) var rotation_max: float = 0.0

@onready var label: Label = %Label
@onready var value_label: Label = %ValueLabel
@onready var marker: Control = %Marker
@onready var reverse_marker := false

var marker_flip := 1

var value := 0.0:
	get:
		return value
	set(val):
		if value != val:
			value = val
			renderData()

func _ready() -> void:
	renderData()

func setData(_label: String, _value_range: Vector2, _value: float, _reverse_marker: bool = false) -> void:
	reverse_marker = _reverse_marker
	label.text = _label
	value_range = _value_range
	value = _value
	renderData()

func renderData() -> void:
	value_label.text = str(Global.round_to_decimals(value, decimals))
	
	var prog: float = getProgress() if !reverse_marker else 1.0 - getProgress()
	var rot: float = lerp(rotation_min, rotation_max, prog)
	marker.rotation_degrees = rot

func getProgress() -> float:
	var progress: float = clamp(value, value_range.x, value_range.y)
	if value < value_range.x:
		progress = 0.0
	elif value > value_range.y:
		progress = 1.0
	else:
		progress = (value - value_range.x) / (value_range.y - value_range.x)

	return progress
