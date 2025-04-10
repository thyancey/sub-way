extends Node2D

@export var max_rope_length := 3000.0  # max depth in pixels
@export var reel_speed := 60.0        # pixels per second
@export var rope_head: RigidBody2D     # Reference to the first segment (RopeHead)
@export var hook: RigidBody2D

var rope_segments = []
# var hook
var current_rope_length := 0.0
var rope_constraint : DampedSpringJoint2D

func _ready():
	# Collect rope segments from the scene
	rope_segments.append(rope_head)
	for segment in get_children():
		if segment != rope_head and segment is RigidBody2D:
			rope_segments.append(segment)

	# Create the hook and attach it to the last segment using the scene's joint
	# hook = hook_scene.instantiate()
	# add_child(hook)

	# Create a DampedSpringJoint2D to act as the rope constraint
	# $RopeConstraint.node_b = hook  # The hook
	$RopeConstraint.rest_length = current_rope_length  # Set the initial length
	$RopeConstraint.damping = 0.5  # Adjust damping as needed for natural movement

func _physics_process(delta):
	handle_input(delta)
	update_rope_visual()

# Handle input to reel the rope in and out
func handle_input(delta):
	if Input.is_action_pressed("reel_down"):
		current_rope_length = min(current_rope_length + reel_speed * delta, max_rope_length)
		$RopeConstraint.rest_length = current_rope_length  # Update rope length in the constraint
	elif Input.is_action_pressed("reel_up"):
		current_rope_length = max(current_rope_length - reel_speed * delta, 0)
		$RopeConstraint.rest_length = current_rope_length  # Update rope length in the constraint

# Update the visual representation of the rope with Line2D
func update_rope_visual():
	var points = []
	var rod_pos = rope_head.global_position
	var target_y = rod_pos.y + current_rope_length

	# Add positions for each rope segment (the physics-controlled ones)
	points.append(to_local(rope_head.global_position))  # Starting from rope_head (first segment)
	for i in range(1, rope_segments.size()):
		var segment = rope_segments[i]
		var segment_position = segment.global_position
		points.append(to_local(segment_position))

	# Add the hook position at the end of the rope
	points.append(to_local(hook.global_position))

	# Update the Line2D points to reflect the rope's length
	$Line2D.points = points
