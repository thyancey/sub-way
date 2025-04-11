extends Node2D

@onready var attach_proxy: RigidBody2D = $AttachProxy
@onready var anchor: RigidBody2D = $Anchor
@onready var joint: PinJoint2D = $Joint

var target_rope_length: float = 5.0
var reel_speed: float = 60.0
var min_rope_length: float = 1.0
var max_rope_length: float = 200.0

func _ready():
	anchor.mass = 5.0
	anchor.gravity_scale = 0.8
	anchor.linear_damp = 1.2
	anchor.angular_damp = 1.0

	update_joint_position()

func _physics_process(delta):
	handle_input(delta)
	move_attach_proxy()
	apply_tension()
	update_joint_position()

func handle_input(delta):
	if Input.is_action_pressed("reel_out"):
		target_rope_length = min(target_rope_length + reel_speed * delta, max_rope_length)
	elif Input.is_action_pressed("reel_in"):
		target_rope_length = max(target_rope_length - reel_speed * delta, min_rope_length)
		print("reel_in", target_rope_length)

func move_attach_proxy():
	# Force the dummy RigidBody2D to follow the submarine exactly
	var global_attach_point = global_position + Vector2.DOWN * target_rope_length
	attach_proxy.global_position = global_attach_point
	attach_proxy.linear_velocity = Vector2.ZERO
	attach_proxy.angular_velocity = 0

func update_joint_position():
	# Reposition joint to match current rope length
	joint.position = attach_proxy.global_position

func apply_tension():
	var anchor_pos = anchor.global_position
	var attach_pos = attach_proxy.global_position
	var dist = anchor_pos.distance_to(attach_pos)
	var slack = dist - 5.0 - target_rope_length  # give it a bit of wiggle room

	if slack > 0:
		var direction = (attach_pos - anchor_pos).normalized()
		var force = direction * slack * 400.0  # tweak this scalar to feel right
		anchor.apply_force(force)

	#uncomment if you want to snap length instead of being springy
	# enforce_length

func enforce_length():
	var anchor_pos = anchor.global_position
	var attach_pos = attach_proxy.global_position
	var dist = anchor_pos.distance_to(attach_pos)
	if dist > target_rope_length + 5.0:
		var correction = (anchor_pos - attach_pos).normalized() * (dist - target_rope_length)
		anchor.global_position = anchor.global_position - correction * 0.5


func _process(_delta):
	queue_redraw()

func _draw():
	var a = attach_proxy.global_position
	var b = anchor.global_position

	# var tension = clamp(anchor.global_position.distance_to(attach_proxy.global_position) - target_rope_length, 0, 100)
	# var color = Color(1, 1 - tension / 100.0, 1 - tension / 100.0)  # reddish as it gets tight
	# draw_line(to_local(a), to_local(b), color, 2.0 + tension / 20.0)
	draw_line(to_local(a), to_local(b), Color.WHITE, 2.0)