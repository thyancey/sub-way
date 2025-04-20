extends Ship_Component

@export var muzzle_distance: float = 35.0
@export var muzzle_ellipse_radius_x: float = 1.0
@export var muzzle_ellipse_radius_y: float = 1.0

@export var charge_time: float = 2.0
@export var charge_auto_fire := 0.0
@export var projectile_scene: PackedScene
@export var charge_curve: Curve
@export var mouse_aim := false
@export var launch_velocity := 300.0
@export_range(0, 360, 1) var angle_degrees: float = 0.0

var charging: bool = false
var charge_timer: float = 0.0
var held_projectile: RigidBody2D = null
var muzzle_offset := Vector2.ZERO
var initial_direction := Vector2.ZERO

func _ready() -> void:
	initial_direction = Vector2.RIGHT.rotated(-deg_to_rad(angle_degrees))

func _process(delta: float) -> void:
	if is_active:
		if mouse_aim:
			initial_direction = (get_global_mouse_position() - global_position).normalized()
			graphic.rotation = initial_direction.angle()

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not charging:
				_start_charge()
			else:
				if held_projectile:
					_update_projectile_position()
				charge_timer += delta
				if charge_auto_fire > 0.0 && charge_timer > charge_auto_fire:
					_release_charge()
			
		else:
			if charging:
				_release_charge()
	else:
		if charging:
			_release_charge()

func _update_projectile_position() -> void:
	# align projectile (position and direction)
	if mouse_aim:
		initial_direction = (get_global_mouse_position() - global_position).normalized()
		graphic.rotation = initial_direction.angle()
	# else:
	# 	initial_direction = Vector2.RIGHT

	muzzle_offset = Vector2(
		initial_direction.x * muzzle_distance * muzzle_ellipse_radius_x,  # Apply ellipse X factor
		initial_direction.y * muzzle_distance * muzzle_ellipse_radius_y   # Apply ellipse Y factor
	)

	held_projectile.rotation = initial_direction.angle()
	held_projectile.global_position = global_position + muzzle_offset

# HOLD STILL WHILE CHARGING!
func _start_charge() -> void:
	charging = true
	charge_timer = 0.0

	held_projectile = projectile_scene.instantiate()
	held_projectile.linear_velocity = Vector2.ZERO

	_update_projectile_position()

	get_tree().current_scene.add_child(held_projectile)

func _release_charge() -> void:
	charging = false

	if held_projectile:
		var charge_ratio = clamp(charge_timer / charge_time, 0.0, 1.0)
		var curve_value = charge_curve.sample(charge_ratio)

		held_projectile.release_charge(initial_direction, curve_value, launch_velocity)

		held_projectile = null

	charge_timer = 0.0
