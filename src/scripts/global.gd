@tool
extends Node

var Scene_PingCircle := preload("res://src/entities/player/component/sonar/ping_circle.tscn")

var particle_scenes := {
	"salvage": preload("res://src/effects/particles/particles_salvage.tscn"),
}

signal updated_darkness(val: float)
signal notified(_type: String, _payload: Variant)
signal ping_spawned(_pos: Vector2,_origin_pos: Vector2, _group: String)

# min/max depth for applying the darkness effect
var darkness_depth := Vector2(50.0, 300.0)
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

func notify(_type: String, _payload: Variant) -> void:
	notified.emit(_type, _payload)

func spawn_particle(_type: String, _pos: Vector2, _overrides: Dictionary = {}):
	if !particle_scenes.has(_type):
		push_warning("No particle scene registered for: " + _type)
		return

	var _particle = particle_scenes[_type].instantiate()
	_particle.global_position = _pos

	for _key in _overrides.keys():
		if _particle.has_method("set_" + _key):
			_particle.call("set_" + _key, _overrides[_key])
		elif _particle.has_method(_key):
			_particle.call(_key, _overrides[_key])
		elif _particle.has_meta(_key):
			_particle.set_meta(_key, _overrides[_key])
		elif _particle.has_property(_key):
			_particle.set(_key, _overrides[_key])
		else:
			push_warning("Property or method '%s' not found on %s" % [_key, _particle.name])

	get_tree().current_scene.add_child(_particle)

func _spawn_ping_circle(_pos: Vector2, _group: String):
	var circle = Scene_PingCircle.instantiate()
	circle.global_position = _pos

	var _color := Color.WHITE
	if _group == "Junk":
		_color = Color(1, 0, 1, 1)
	elif _group == "Enemy":
		_color = Color(1, 0, 0, 1)
	circle.color = _color
	get_tree().current_scene.add_child(circle)

func ping(_pos: Vector2, _origin_pos: Vector2, _group: String) -> void:
	ping_spawned.emit(_pos, _origin_pos, _group)
	_spawn_ping_circle(_pos, _group)

