extends Ship_Component

@export var muzzle_distance: float = 35.0
@export var muzzle_ellipse_radius_x: float = 1.0
@export var muzzle_ellipse_radius_y: float = 0.5

@export var charge_time: float = 2.0
@export var charge_auto_fire := 0.0
@export var projectile_scene: PackedScene
@export var charge_curve: Curve
@export var launch_point: Marker2D
@export var mouse_aim := false
@onready var graphic := %Graphic

var charging: bool = false
var charge_timer: float = 0.0
var held_projectile: RigidBody2D = null
var initial_direction := Vector2.ZERO  # Store the initial rotation when charging starts

func _process(delta: float) -> void:
	if is_active:
		if mouse_aim:
			initial_direction = (get_global_mouse_position() - global_position).normalized()
			graphic.rotation = initial_direction.angle()

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not charging:
				_start_charge()
			else:
				charge_timer += delta
				if charge_auto_fire > 0.0 && charge_timer > charge_auto_fire:
					_release_charge()
		else:
			if charging:
				_release_charge()
	else:
		if charging:
			_release_charge()

# HOLD STILL WHILE CHARGING!
func _start_charge() -> void:
	charging = true
	charge_timer = 0.0

	held_projectile = projectile_scene.instantiate()
	held_projectile.direction = Vector2.ZERO
	held_projectile.acceleration = 0.0
	held_projectile.linear_velocity = Vector2.ZERO

	# align projectile (position and direction)
	if mouse_aim:
		initial_direction = (get_global_mouse_position() - global_position).normalized()
		graphic.rotation = initial_direction.angle()
	else:
		initial_direction = Vector2.RIGHT
	# var muzzle_offset = initial_direction * muzzle_distance
	var muzzle_offset = Vector2(
		initial_direction.x * muzzle_distance * muzzle_ellipse_radius_x,  # Apply ellipse X factor
		initial_direction.y * muzzle_distance * muzzle_ellipse_radius_y   # Apply ellipse Y factor
	)

	held_projectile.direction = initial_direction
	held_projectile.rotation = initial_direction.angle()
	held_projectile.global_position = global_position + muzzle_offset

	get_tree().current_scene.add_child(held_projectile)

func _release_charge() -> void:
	charging = false

	if held_projectile:
		var charge_ratio = clamp(charge_timer / charge_time, 0.0, 1.0)
		var curve_value = charge_curve.sample(charge_ratio)

		held_projectile.direction = initial_direction
		held_projectile.rotation = initial_direction.angle()
		held_projectile.speed_mod = curve_value
		held_projectile.release_charge()

		held_projectile = null

	charge_timer = 0.0
