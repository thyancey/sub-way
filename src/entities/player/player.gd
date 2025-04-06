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

@onready var surface_detector = %Detector # Reference to the SurfaceDetector Area2D
@onready var bubble_particles = %BubbleParticles # Reference to the BubbleParticles node
@onready var bubble_particles2 = %BubbleParticles2 # Reference to the BubbleParticles node
@onready var light: PointLight2D = %Light

enum SubmarineState {SUBMERGED, SURFACED} # Enum for state management
var current_state: SubmarineState = SubmarineState.SUBMERGED # Default state is submerged

var idle_timer := 0.0
var actively_submerging := false

func _ready() -> void:
	# Connect the signal to detect when the SurfaceDetector collides with something in the "Surface" layer
	surface_detector.area_entered.connect(_on_surface_reached)
	bubble_particles.emitting = false
	bubble_particles2.emitting = false
	
	Global.connect('updated_darkness', on_updated_darkness)
	on_updated_darkness(Global.calc_darkness(Global.depth))

func on_updated_darkness(darkness_percent: float) -> void:
	light.energy = lerp(0.0, 1.6, darkness_percent)

func _physics_process(delta: float) -> void:
	if current_state == SubmarineState.SUBMERGED:
		handle_submerged(delta)
	elif current_state == SubmarineState.SURFACED:
		handle_surfaced(delta)

	Global.depth = position.y

# Handle submerged behavior
func handle_submerged(delta: float) -> void:
	var input_dir = Vector2.ZERO

	# Input for movement
	if Input.is_action_pressed("RIGHT"):
		input_dir.x += 1
	if Input.is_action_pressed("LEFT"):
		input_dir.x -= 1
	if Input.is_action_pressed("UP"):
		input_dir.y -= 1
	if Input.is_action_pressed("DOWN"):
		input_dir.y += 1

		actively_submerging = true
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

	# Input for movement
	if Input.is_action_pressed("RIGHT"):
		input_dir.x += 1
	if Input.is_action_pressed("LEFT"):
		input_dir.x -= 1
	if Input.is_action_pressed("DOWN"):
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
	print("Switched to submerged")

func set_surfaced() -> void:
	current_state = SubmarineState.SURFACED
	trigger_splash()
	print("Switched to surfaced")

func trigger_splash() -> void:
	print('splash')
