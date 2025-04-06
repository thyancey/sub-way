@tool
extends Node

signal updated_depth(val: int)
signal updated_darkness(val: float)
signal updated_oxygen(val: float)

var start_depth: float = 20.0
var end_depth: float = 150.0

var max_oxygen := 100.0

var depth := 0:
	get:
		return depth
	set(value):
		if depth != value:
			depth = value
			updated_depth.emit(depth)
			updated_darkness.emit(calc_darkness(depth))

var oxygen := max_oxygen:
	get:
		return oxygen
	set(value):
		# var new_value: float = round_to_decimals(clamp(value, 0.0, 1.0), 2)
		# print("new_value: ", new_value)
		var new_value: float = clamp(value, 0.0, max_oxygen)
		if oxygen != new_value:
			oxygen = new_value
			updated_oxygen.emit(new_value)

func _ready() -> void:
	print("ready")

func calc_darkness(_depth) -> float:
	var darkness_percent: float = clamp(depth, start_depth, end_depth)
	if depth < start_depth:
		darkness_percent = 0.0
	elif depth > end_depth:
		darkness_percent = 1.0
	else:
		darkness_percent = (depth - start_depth) / (end_depth - start_depth)

	return darkness_percent
