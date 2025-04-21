extends RigidBody2D

@export var damage := 0.0
@export var health := 0.0
@export var lifetime: float = 8.0
@export var direction: Vector2 = Vector2.ZERO
@export var age_when_charging := false

@onready var main_sprite: AnimatedSprite2D = %MainSprite

var life_timer: float = 0.0
var is_charging := true
var initial_gravity_scale := 0.0

func _ready() -> void:
	initial_gravity_scale = gravity_scale
	gravity_scale = 0.0
	main_sprite.play("charge")

func _physics_process(delta: float) -> void:
	if is_charging:
		linear_velocity = Vector2.ZERO

	if age_when_charging || !is_charging:
		life_timer += delta
		# print(life_timer, " vs ", lifetime)
		if life_timer >= lifetime:
			queue_free()

func _on_area_2d_body_entered(_body:Node2D) -> void:
	if _body.is_in_group("Enemy"):
		if damage > 0.0:
			_body.hit()
		if health > 0.0:
			health -= 1.0
			if health <= 0.0:
				queue_free()

func release_charge(_direction: Vector2, _speed_mod: float, _launch_velocity: float) -> void:
	is_charging = false
	direction = _direction
	main_sprite.play("idle")
	gravity_scale = initial_gravity_scale
	apply_impulse(direction * _speed_mod * _launch_velocity)
	
