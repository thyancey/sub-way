extends Node2D

@export var max_rope_length := 3000.0  # max depth in pixels
@export var reel_speed := 60.0        # pixels per second
@export var hook: RigidBody2D
@export var rope_anchor: StaticBody2D
@export var rope_segment: RigidBody2D

var rope_segments = []
# var hook
var current_rope_length := 0.0

func _ready():
	pass
	# rope_joint.rest_length = current_rope_length  # Set the initial length
	# rope_joint.damping = 0.5  # Adjust damping as needed for natural movement

func _physics_process(delta):
	handle_input(delta)
	update_rope_visual()

# Handle input to reel the rope in and out
func handle_input(delta):
	if Input.is_action_pressed("reel_down"):
		current_rope_length = min(current_rope_length + reel_speed * delta, max_rope_length)
		# rope_joint.rest_length = current_rope_length  # Update rope length in the constraint
	elif Input.is_action_pressed("reel_up"):
		current_rope_length = max(current_rope_length - reel_speed * delta, 0)
		# rope_joint.rest_length = current_rope_length  # Update rope length in the constraint
	print("rope_legnth", current_rope_length)

# Update the visual representation of the rope with Line2D
func update_rope_visual():
	var points = []

	# Add positions for each rope segment (the physics-controlled ones)
	points.append(to_local(rope_anchor.global_position))  # Starting from rope_head (first segment)
	# for i in range(1, rope_segments.size()):
	# 	var segment = rope_segments[i]
	# 	var segment_position = segment.global_position
	# 	points.append(to_local(segment_position))

	# Add the hook position at the end of the rope
	points.append(to_local(hook.global_position))

	# Update the Line2D points to reflect the rope's length
	$Line2D.points = points
