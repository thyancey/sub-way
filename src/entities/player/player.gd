extends CharacterBody2D

@export var vertical_acceleration: float = 50.0
@export var max_ascend_speed: float = 20.0
@export var max_descend_speed: float = 10.0
@export var drag: float = 500.0
@export var gravity_force: float = 40.0
@export var fast_dive_multiplier: float = 3.0

@export var submerged_bob_strength: float = 1.0
@export var submerged_bob_speed: float = 2.0
@export var submerged_horizontal_acceleration: float = 20.0
@export var submerged_horizontal_max: float = 20.0
@export var submerged_horizontal_damp: float = 2.0

@export var surface_bob_strength: float = 5.0
@export var surface_bob_speed: float = 10.0
@export var surface_horizontal_acceleration: float = 20.0
@export var surface_horizontal_max: float = 20.0
@export var surface_horizontal_damp: float = 2.0

@onready var surface_detector = %Detector
@onready var bubble_particles = %BubbleParticles
@onready var bubble_particles2 = %BubbleParticles2
@onready var surface_particles = %SurfaceParticles
@onready var light: PointLight2D = %Light

@onready var oxygen_recharge := 0.5
var lamp_scale := Vector2(0.0, 5.0)

var active_component_idx := 0
var components: Array[Node2D] = []

# max depth, idle deplation, descending depletion
var decay_table = [
	[05, .1, 1.0],
	[200, .4, 4.0],
	[300, .8, 8.0]
]

func _get_last_greater_index(arr: Array, input: float) -> int:
	for i in range(arr.size() - 1, -1, -1):
		if input > arr[i]:
			return i
	return -1

func _get_decay_data(input: float) -> Array:
	for i in range(decay_table.size() - 1, -1, -1):
		if input >= decay_table[i][0]:
			return decay_table[i]
	return []

func _get_decay_rate(_depth: float, is_descending: bool) -> float:
	if _depth < decay_table[0][0]:
		# Below first threshold, decay is 0
		return 0.0
	
	var _decay_data = _get_decay_data(_depth)
	return _decay_data[2] if is_descending else _decay_data[1]

@onready var MainSprite: AnimatedSprite2D = %MainSprite

enum SubmarineState {SUBMERGED, SURFACED} # Enum for state management
var current_state: SubmarineState = SubmarineState.SUBMERGED # Default state is submerged

var idle_timer := 0.0
var actively_submerging := false

enum SubmarineStatus {DESCENDING, ASCENDING, IDLE}
var sub_status: SubmarineStatus = SubmarineStatus.IDLE

func _ready() -> void:
	# Connect the signal to detect when the SurfaceDetector collides with something in the "Surface" layer
	surface_detector.area_entered.connect(_on_surface_reached)
	bubble_particles.emitting = false
	bubble_particles2.emitting = false

	for child in get_children():
		if child.is_in_group("Component"):
			components.append(child)
	swap_component(active_component_idx)

func _physics_process(delta: float) -> void:
	if current_state == SubmarineState.SUBMERGED:
		handle_submerged(delta)
	elif current_state == SubmarineState.SURFACED:
		handle_surfaced(delta)

	Global.player_data.depth = int(position.y)

	if sub_status == SubmarineStatus.DESCENDING:
		var decay_rate = _get_decay_rate(Global.player_data.depth, true)
		Global.player_data.oxygen -= decay_rate * delta
	elif sub_status == SubmarineStatus.ASCENDING:
		var decay_rate = _get_decay_rate(Global.player_data.depth, false)
		Global.player_data.oxygen -= decay_rate * delta
	else:
		if current_state == SubmarineState.SURFACED:
			Global.player_data.oxygen += oxygen_recharge
		else:
			# moving left and right?
			var decay_rate = _get_decay_rate(Global.player_data.depth, false)
			Global.player_data.oxygen -= decay_rate * delta

	match (sub_status):
		SubmarineStatus.IDLE:
			if abs(velocity.x) < 5:
				MainSprite.play('idle')
			elif velocity.x < 0:
				MainSprite.play('ascending_left')
			else:
				MainSprite.play('ascending_right')
		SubmarineStatus.ASCENDING:
			if abs(velocity.x) < 5:
				MainSprite.play('ascending')
			elif velocity.x < 0:
				MainSprite.play('ascending_left')
			else:
				MainSprite.play('ascending_right')

		SubmarineStatus.DESCENDING:
			if abs(velocity.x) < 5:
				MainSprite.play('descending')
			elif velocity.x < 0:
				MainSprite.play('descending_left')
			else:
				MainSprite.play('descending_right')

# Handle submerged behavior
func handle_submerged(delta: float) -> void:
	var input_dir = Vector2.ZERO
	sub_status = SubmarineStatus.IDLE

	# Input for movement
	if Input.is_action_pressed("RIGHT"):
		input_dir.x += 1
	if Input.is_action_pressed("LEFT"):
		input_dir.x -= 1
	if Input.is_action_pressed("UP"):
		sub_status = SubmarineStatus.ASCENDING
		input_dir.y -= 1
	if Input.is_action_pressed("DOWN"):
		input_dir.y += 1

		actively_submerging = true
		sub_status = SubmarineStatus.DESCENDING
		bubble_particles.emitting = true
		bubble_particles2.emitting = true
	else:
		actively_submerging = false
		bubble_particles.emitting = false
		bubble_particles2.emitting = false

	# Horizontal movement
	if input_dir.x != 0:
		velocity.x = move_toward(velocity.x, input_dir.x * submerged_horizontal_max, submerged_horizontal_acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, submerged_horizontal_damp * delta)

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

	# Handle rotation
	rotation = lerp(rotation, velocity.y * 0.002, 5 * delta)
	rotation = clamp(rotation, deg_to_rad(-10), deg_to_rad(10))

	# Move the submarine
	move_and_slide()

	# Idle bobbing effect
	if input_dir == Vector2.ZERO:
		idle_timer += delta
		var bob = sin(idle_timer * submerged_bob_speed) * submerged_bob_strength * delta
		position.y += bob
	else:
		idle_timer = 0.0

# Handle surfaced behavior (no movement allowed)
func handle_surfaced(delta: float) -> void:
	var input_dir = Vector2.ZERO
	sub_status = SubmarineStatus.IDLE

	# Input for movement
	if Input.is_action_pressed("RIGHT"):
		input_dir.x += 1
	if Input.is_action_pressed("LEFT"):
		input_dir.x -= 1
	if Input.is_action_pressed("DOWN"):
		sub_status = SubmarineStatus.DESCENDING
		actively_submerging = true
		set_submerged()
		return

	# Horizontal movement
	if input_dir.x != 0:
		velocity.x = move_toward(velocity.x, input_dir.x * surface_horizontal_max, surface_horizontal_acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, surface_horizontal_damp * delta)

	velocity.y = 0

	# Optional: handle bobbing on surface
	idle_timer += delta
	var bob = sin(idle_timer * surface_bob_speed) * surface_bob_strength * delta
	position.y += bob


	rotation = lerp(rotation, velocity.y * 0.002, 5 * delta)
	rotation = clamp(rotation, deg_to_rad(-10), deg_to_rad(10))

	# We don't move, and we just need to display the idle or surface behavior here
	move_and_slide()

# Signal handler for when the submarine enters the surface
func _on_surface_reached(area: Area2D) -> void:
	if !actively_submerging && area.is_in_group("Surface"):
		if current_state == SubmarineState.SUBMERGED:
			set_surfaced()
		else:
			trigger_splash()

func set_submerged() -> void:
	current_state = SubmarineState.SUBMERGED
	surface_particles.emitting = false
	print("Switched to submerged")

func set_surfaced() -> void:
	current_state = SubmarineState.SURFACED
	surface_particles.emitting = true
	trigger_splash()
	print("Switched to surfaced")

func trigger_splash() -> void:
	print('splash')

func _input(_delta) -> void:
	if Input.is_action_just_pressed("COMPONENT_SWAP"):
		swap_component()

func swap_component(_force_idx := -1):
	if _force_idx > -1:
		active_component_idx = _force_idx
		for i in components.size():
			components[i].is_active = true if i == _force_idx else false
	else:
		components[active_component_idx].is_active = false
		active_component_idx = (active_component_idx + 1) % components.size()
		components[active_component_idx].is_active = true
	Global.player_data.active_component_name = components[active_component_idx].display_name
