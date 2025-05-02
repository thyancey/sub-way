extends Control

var Scene_Blip := preload("res://src/ui/gauge/radar_blip.tscn")

@export var radius := 22.0
@export var distance_curve: Curve

@export var sweep_length := 22.0
@export var color_junk := Color(1, 0, 1, .9)
@export var color_enemy := Color(1, 0, 0, .9)
@export var center_offset := Vector2.ZERO
@export var flash_duration := 0.5

@onready var animation: AnimationPlayer = %AnimationPlayer

var sweep_angle := 0.0
@export var sweep_speed := PI  # radians per second

@onready var pings: Node2D = %Pings
@onready var gauge: Node2D = %Gauge
@onready var sweep_arm: Control = %sweep_arm

var flash_timer: Timer = null

func _ready() -> void:
	Global.connect("ping_spawned", _on_ping_spawned)

func _on_ping_spawned(_pos: Vector2, _origin_pos: Vector2, _group: String) -> void:
	var _b: Node2D = Scene_Blip.instantiate()
	_b.position = _get_ping_position(_origin_pos, _pos, radius, Global.player_data.ping_range)
	if (!flash_timer):
		flash_timer = Timer.new()
		flash_timer.one_shot = true
		flash_timer.autostart = true
		flash_timer.wait_time = flash_duration
		flash_timer.timeout.connect(_on_flash_timer_timeout)
		add_child(flash_timer)
		animation.play('flash')

	var _color := Color.WHITE
	if _group == "Junk":
		_color = color_junk
	elif _group == "Enemy":
		_color = color_enemy

	_b.modulate = _color
	_b.orig_origin = _origin_pos
	pings.add_child(_b)

func _on_flash_timer_timeout() -> void:
	if flash_timer:
		remove_child(flash_timer)
		flash_timer = null

func _get_ping_position(player_pos: Vector2, ping_pos: Vector2, radar_radius: float, max_radar_distance: float) -> Vector2:
	var delta = ping_pos - player_pos
	var distance = delta.length()
	var direction = delta.normalized()

	var t: float = clamp(distance / max_radar_distance, 0.0, 1.0)
	var curved_t := t
	if distance_curve != null:
		curved_t = distance_curve.sample(t)

	var radar_distance = curved_t * radar_radius
	return direction * radar_distance

func _process(delta: float) -> void:
	sweep_angle = wrapf(sweep_angle + sweep_speed * delta, 0.0, TAU)
	sweep_arm.sweep_angle = sweep_angle

	if flash_timer:
		var radar_center = global_position + center_offset

		for ping in pings.get_children():
			var ping_global = ping.global_position
			var angle_to_ping = (ping_global - radar_center).angle()
			var diff = shortest_angle_difference(angle_to_ping, sweep_angle)

			if abs(diff) <= deg_to_rad(5.0):  # sweep tolerance
				ping.reveal()
	
	# queue_redraw()

func shortest_angle_difference(a: float, b: float) -> float:
	var diff = fmod((a - b + PI), TAU) - PI
	return diff

# func _draw():
	# sweep_arm.draw_arm(sweep_angle)
