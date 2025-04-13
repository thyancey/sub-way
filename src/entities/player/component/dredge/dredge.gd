extends Ship_Component

@export var reel_strength := 800 # heavier anchor needs bigger number to keep it up
@export var anchor_mass := 20.0

@onready var attach_proxy: RigidBody2D = $AttachProxy
@onready var anchor: RigidBody2D = $Anchor
@onready var joint: PinJoint2D = $Joint

var target_rope_length: float = 5.0
var reel_speed: float = 60.0
var min_rope_length: float = 1.0
var max_rope_length: float = 200.0

var is_grabbing := false


func _ready():
	super._ready()
	anchor.connect("object_grabbed", _on_object_grabbed)
	anchor.connect("object_released", _on_object_released)
	anchor.mass = anchor_mass
	anchor.gravity_scale = 0.2
	anchor.linear_damp = 4.0
	anchor.angular_damp = 5.0

	update_joint_position()

func _physics_process(delta):
	handle_input(delta)
	move_attach_proxy()
	apply_tension()
	update_joint_position()
	enforce_length()
	Global.player_data.rope_length = calc_real_length()
	# if Global.player_data.rope_length > target_rope_length + 5:
	# 	target_rope_length = Global.player_data.rope_length

func set_rope_length(value: float) -> void:
	var clamped = clamp(value, min_rope_length, max_rope_length)
	target_rope_length = clamped

func calc_real_length():
	var dist = attach_proxy.global_position.distance_to(anchor.global_position)
	# print(target_rope_length, ' | ', dist)
	return dist

func handle_input(delta):
	if is_active:
		if Input.is_action_pressed("reel_out"):
			set_rope_length(target_rope_length + reel_speed * delta)
		elif Input.is_action_pressed("reel_in"):
			set_rope_length(target_rope_length - reel_speed * delta)
		elif Input.is_action_pressed("reel_in"):
			set_rope_length(target_rope_length - reel_speed * delta)

		if Input.is_action_just_pressed("ACTIVATE_COMPONENT"):
			anchor.toggle_grabbing()


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
	var a = attach_proxy.global_position
	var b = anchor.global_position
	draw_line(to_local(a), to_local(b), Color.WHITE, 0.5)

func _on_object_grabbed(_object: Node2D) -> void:
	Global.notify("GRAB", _object)

func _on_object_released() -> void:
	Global.notify("GRAB", null)
