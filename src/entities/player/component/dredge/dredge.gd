extends Ship_Component

@export var reel_strength := 800 # heavier anchor needs bigger number to keep it up
@export var anchor_mass := 20.0
@export var anchor_scene: PackedScene

@onready var attach_proxy: RigidBody2D = $AttachProxy
# @onready var anchor: RigidBody2D = $Anchor
@onready var joint: PinJoint2D = $Joint
var anchor: RigidBody2D = null

var INITIAL_ROPE_LENGTH := 5.0
var target_rope_length := INITIAL_ROPE_LENGTH
var reel_speed: float = 60.0
var min_rope_length: float = 1.0
var col_mask: Array
var is_anchor_extended := false


func _ready():
	super._ready()

func _create_anchor() -> void:
	anchor = anchor_scene.instantiate()
	anchor.connect("object_grabbed", _on_object_grabbed)
	anchor.connect("object_released", _on_object_released)
	anchor.mass = anchor_mass
	anchor.gravity_scale = 0.2
	anchor.linear_damp = 4.0
	anchor.angular_damp = 5.0
	add_child(anchor)
	joint.node_b = joint.get_path_to(anchor)
	target_rope_length = INITIAL_ROPE_LENGTH

	update_joint_position()
	is_anchor_extended = true

func _destroy_anchor() -> void:
	if is_anchor_extended:
		joint.node_b = NodePath("")
		remove_child(anchor)
		anchor.queue_free()
		is_anchor_extended = false

func _physics_process(_delta: float):
	if is_anchor_extended:
		_handle_input(_delta)
		move_attach_proxy()
		apply_tension()
		update_joint_position()
		enforce_length()
		Global.player_data.rope_length = calc_real_length()

func set_rope_length(value: float) -> void:
	var clamped = clamp(value, Global.player_data.rope_range.x, Global.player_data.rope_range.y)
	target_rope_length = clamped

func calc_real_length():
	var dist = attach_proxy.global_position.distance_to(anchor.global_position)
	return dist

func _handle_input(_delta: float):
	if is_active:
		if Input.is_action_pressed("COMPONENT_ACTIVATE"):
			_reel_out(_delta)
		else:
			_reel_in(_delta)

		# if Input.is_action_pressed("reel_out"):
		# 	_reel_out(_delta)
		# elif Input.is_action_pressed("reel_in"):
		# 	_reel_in(_delta)

		if Input.is_action_just_pressed("COMPONENT_MODE"):
			anchor.toggle_grabbing()

func _reel_in(_delta: float) -> void:
	set_rope_length(target_rope_length - reel_speed * _delta)

func _reel_out(_delta: float) -> void:
	set_rope_length(target_rope_length + reel_speed * _delta)


# Attach proxy's position should remain fixed relative to the submarine.
# It doesn't change based on rope length, but instead follows the submarine's movement.
func move_attach_proxy():
	# The attach proxy should be fixed in the submarine, not changing based on rope length directly.
	attach_proxy.global_position = global_position

	# Ensure no unintended movement
	attach_proxy.linear_velocity = Vector2.ZERO
	attach_proxy.angular_velocity = 0

func update_joint_position():
	joint.position = attach_proxy.global_position

func apply_tension():
	var anchor_pos = anchor.global_position
	var attach_pos = attach_proxy.global_position
	var dist = anchor_pos.distance_to(attach_pos)
	var slack = dist - 5.0 - target_rope_length # give it a bit of wiggle room

	if slack > 0:
		var direction = (attach_pos - anchor_pos).normalized()
		var force = direction * slack * reel_strength
		anchor.apply_force(force)

# If you want the rope to snap to the target length instead of being springy:
func enforce_length():
	var anchor_pos = anchor.global_position
	var attach_pos = attach_proxy.global_position
	var dist = anchor_pos.distance_to(attach_pos)
	if dist > target_rope_length + 5.0:
		pass
		# var correction = (anchor_pos - attach_pos).normalized() * (dist - target_rope_length)
		# anchor.global_position = anchor.global_position - correction * 0.5
	elif target_rope_length > dist + 5.0:
		target_rope_length = dist


# draw the rope
func _process(_delta):
	queue_redraw()

func _draw():
	if is_anchor_extended:
		var a = attach_proxy.global_position
		var b = anchor.global_position
		draw_line(to_local(a), to_local(b), Color.WHITE, 0.5)

func _on_object_grabbed(_object: Node2D) -> void:
	Global.notify("GRAB", _object)

func _on_object_released() -> void:
	Global.notify("GRAB", null)

func _on_active_changed(_val: bool):
	super._on_active_changed(_val)

	if _val:
		_create_anchor()
	else:
		_destroy_anchor()
