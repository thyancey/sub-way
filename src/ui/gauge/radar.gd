extends Control
var Scene_Blip := preload("res://src/ui/gauge/radar_blip.tscn")

@export var radius := 22.0
@export var distance_curve: Curve

func _ready() -> void:
	Global.connect("ping_spawned", _on_ping_spawned)

func _on_ping_spawned(_pos: Vector2, _origin_pos: Vector2, _group: String) -> void:
	var _b: Node2D = Scene_Blip.instantiate()
	_b.position = _get_ping_position(_origin_pos, _pos, radius, Global.player_data.ping_range)

	var _color := Color.WHITE
	if _group == "Junk":
		_color = Color(1, 0, 1, .9)
	elif _group == "Enemy":
		_color = Color(1, 0, 0, .9)
	_b.modulate = _color
	add_child(_b)

func _get_ping_position(player_pos: Vector2, ping_pos: Vector2, radar_radius: float, max_radar_distance: float) -> Vector2:
	var delta = ping_pos - player_pos
	var distance = delta.length()
	var direction = delta.normalized()

	# Normalize and clamp distance
	var t: float = clamp(distance / max_radar_distance, 0.0, 1.0)
	var curved_t := t

	if distance_curve != null:
		curved_t = distance_curve.sample(t)

	# Scale to radar radius
	var radar_distance = curved_t * radar_radius

	return direction * radar_distance
