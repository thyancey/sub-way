@tool
extends Control

@export var value_range := Vector2(0.0, 100.0)
@export var decimals := 1
@export var height := 140

@onready var label: Label = %Label
@onready var start_label: Label = %StartLabel
@onready var end_label: Label = %EndLabel
@onready var marker: Control = %Marker
@onready var value_label: Label = %ValueLabel
@onready var reverse_marker := false
@onready var line: ColorRect = %Line

var marker_flip := 1
var orig_label_pos := Vector2.ZERO

var value := 0.0:
	get:
		return value
	set(val):
		if value != val:
			value = val
			renderData()

func _ready() -> void:
	renderData()
	orig_label_pos = label.position

func setData(_label: String, _value_range: Vector2, _value: float, _reverse_marker: bool = false) -> void:
	reverse_marker = _reverse_marker
	label.text = _label
	value_range = _value_range
	start_label.text = str(value_range.x)
	end_label.text = str(value_range.y)
	value = _value
	line.size.y = height
	end_label.position.y = height + 5
	label.position.y = orig_label_pos.y + (float(height) / 2)

	renderData()

func renderData() -> void:
	value_label.text = str(Global.round_to_decimals(value, decimals))

	
	var prog: float = getProgress() if !reverse_marker else 1.0 - getProgress()
	marker.position.y = prog * height
	# var rot: float = lerp(rotation_min, rotation_max, prog)
	# marker.rotation_degrees = rot

func getProgress() -> float:
	var progress: float = clamp(value, value_range.x, value_range.y)
	if value < value_range.x:
		progress = 0.0
	elif value > value_range.y:
		progress = 1.0
	else:
		progress = (value - value_range.x) / (value_range.y - value_range.x)

	return progress
