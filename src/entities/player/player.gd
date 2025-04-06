extends CharacterBody2D

@export var vertical_acceleration: float = 50.0
@export var horizontal_acceleration: float = 20.0
@export var max_horizontal_speed: float = 20.0
@export var max_ascend_speed: float = 20.0
@export var max_descend_speed: float = 10.0
@export var drag: float = 500.0
@export var gravity_force: float = 40.0
@export var idle_bob_strength: float = 2.0
@export var idle_bob_speed: float = 1.0
@export var horizontal_damp: float = 2.0 # Used in lerp
@export var fast_dive_multiplier: float = 3.0

var idle_timer := 0.0

func _physics_process(delta: float) -> void:
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("RIGHT"):
		input_dir.x += 1
	if Input.is_action_pressed("LEFT"):
		input_dir.x -= 1
	if Input.is_action_pressed("UP"):
		input_dir.y -= 1
	if Input.is_action_pressed("DOWN"):
		input_dir.y += 1

	# Horizontal movement
	if input_dir.x != 0:
		velocity.x = move_toward(velocity.x, input_dir.x * max_horizontal_speed, horizontal_acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, horizontal_damp * delta)

	# Vertical movement
	if input_dir.y != 0:
		if input_dir.y < 0:
			# Ascending (negative y)
			velocity.y = move_toward(velocity.y, input_dir.y * max_ascend_speed, vertical_acceleration * delta)
		else:
			# Diving (positive y)
			if Input.is_action_pressed("BOOST"):
				velocity.y = move_toward(velocity.y, input_dir.y * max_descend_speed * fast_dive_multiplier, vertical_acceleration * delta)
			else:
				velocity.y = move_toward(velocity.y, input_dir.y * max_descend_speed, vertical_acceleration * delta)
	else:
		# No vertical input: apply gravity to slowly sink
		velocity.y = move_toward(velocity.y, 0.0, gravity_force * delta)

	rotation = lerp(rotation, velocity.y * 0.002, 5 * delta)
	rotation = clamp(rotation, deg_to_rad(-10), deg_to_rad(10))

	if abs(velocity.x) < 0.01:
			velocity.x = 0.0

	move_and_slide()

	if input_dir == Vector2.ZERO:
		idle_timer += delta
		var bob = sin(idle_timer * idle_bob_speed) * idle_bob_strength * delta
		position.y += bob
	else:
		idle_timer = 0.0
