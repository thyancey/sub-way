extends RigidBody2D

@export var damage := 0.0
@export var health := 0.0
@export var max_speed: float = 600.0
@export var acceleration: float = 500.0
@export var lifetime: float = 8.0
@export var speed_mod: float = 0.0

@export var acceleration_range := Vector2(40.0, 2000.0)
@export var speed_range := Vector2(600.0, 1200.0)

@onready var main_sprite: AnimatedSprite2D = %MainSprite

var direction: Vector2 = Vector2.ZERO
var life_timer: float = 0.0
var current_speed: float = 0.0

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
	else:
		linear_velocity = Vector2.ZERO

func _on_area_2d_body_entered(_body:Node2D) -> void:
	if _body.is_in_group("Enemy"):
		if damage > 0.0:
			_body.hit()
		if health > 0.0:
			health -= 1.0
			if health <= 0.0:
				queue_free()

func release_charge() -> void:
	main_sprite.play("idle")
	acceleration = lerp(acceleration_range.x, acceleration_range.y, speed_mod)
	max_speed = lerp(speed_range.x, speed_range.y, speed_mod)
	
