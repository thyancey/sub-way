@tool
extends Node

signal updated_darkness(val: float)

# min/max depth for applying the darkness effect
var darkness_depth := Vector2(50.0, 150.0)
var player_data: PlayerData = null

func _init() -> void:
	player_data = PlayerData.new()
	player_data.connect('updated_depth', _on_updated_depth)

func _on_updated_depth(_depth) -> void:
	updated_darkness.emit(calc_darkness(_depth))

func calc_darkness(_depth) -> float:
	var darkness_percent: float = clamp(_depth, darkness_depth.x, darkness_depth.y)
	if _depth < darkness_depth.x:
		darkness_percent = 0.0
	elif _depth > darkness_depth.y:
		darkness_percent = 1.0
	else:
		darkness_percent = (_depth - darkness_depth.x) / (darkness_depth.y - darkness_depth.x)

	return darkness_percent

func round_to_decimals(value: float, decimals: int) -> float:
	var multiplier = pow(10.0, decimals)
	return round(value * multiplier) / multiplier