@tool
extends Node

signal updated_depth(val: int)
signal updated_darkness(val: float)
signal updated_oxygen(val: float)

# min/max depth for applying the darkness effect
var darkness_depth := Vector2(20.0, 150.0)
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
	var darkness_percent: float = clamp(depth, darkness_depth.x, darkness_depth.y)
	if depth < darkness_depth.x:
		darkness_percent = 0.0
	elif depth > darkness_depth.y:
		darkness_percent = 1.0
	else:
		darkness_percent = (depth - darkness_depth.x) / (darkness_depth.y - darkness_depth.x)

	return darkness_percent
