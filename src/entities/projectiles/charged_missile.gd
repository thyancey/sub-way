extends RigidBody2D

@export var damage := 0.0
@export var health := 0.0
@export var max_speed: float = 600.0
@export var acceleration: float = 500.0
@export var lifetime: float = 8.0
@export var direction: Vector2 = Vector2.ZERO

@export var acceleration_range := Vector2(40.0, 2000.0)
@export var speed_range := Vector2(600.0, 1200.0)

@onready var main_sprite: AnimatedSprite2D = %MainSprite

var life_timer: float = 0.0
var current_speed: float = 0.0

var previous_velocity := Vector2.ZERO
var velocity_drop_threshold := 20.0 #when a drop in velocity > this is detected, detonate

func _ready() -> void:
	gravity_scale = 0.0
	main_sprite.play("charge")

func _physics_process(delta: float) -> void:
	life_timer += delta
	if life_timer >= lifetime:
		queue_free()
		
	if direction != Vector2.ZERO:
		current_speed = min(current_speed + acceleration * delta, max_speed)
		var target_velocity = direction * current_speed
		linear_velocity = linear_velocity.lerp(target_velocity, 0.1)

		_check_for_impact()
	else:
		linear_velocity = Vector2.ZERO

# since collisions with tilemaps can't be easily detected (but the physics collision happens),
# if a sudden drop in velocity is sensed, you've probably hit something, so detonate!
func _check_for_impact() -> void:
	var current_velocity = linear_velocity
	var delta_velocity = previous_velocity.length() - current_velocity.length()

	if delta_velocity > velocity_drop_threshold:
		# print("Likely impact! Δv =", delta_velocity)
		_detonate()

	previous_velocity = current_velocity

func _detonate() -> void:
	print("_detonate")
	queue_free()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Enemy"):
		if damage > 0.0:
			_body.hit()
		if health > 0.0:
			health -= 1.0
			if health <= 0.0:
				queue_free()

func release_charge(_direction: Vector2, _speed_mod: float, _launch_velocity: float) -> void:
	main_sprite.play("idle")
	direction = _direction
	acceleration = lerp(acceleration_range.x, acceleration_range.y, _speed_mod)
	max_speed = lerp(speed_range.x, speed_range.y, _speed_mod)
