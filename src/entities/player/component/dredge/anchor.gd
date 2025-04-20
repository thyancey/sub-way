extends RigidBody2D

signal object_grabbed(object: Node2D)
signal object_released()
signal updated_is_grabbing(is_grabbing: bool)

@onready var collision_open: CollisionPolygon2D = %Collision_Open
@onready var collision_closed: CollisionShape2D = %Collision_Closed

@export var is_grabbing := false:
	get:
		return is_grabbing
	set(value):
		if is_grabbing != value:
			is_grabbing = value
			updated_is_grabbing.emit(is_grabbing)

var current_joint: PinJoint2D = null
var grabbed_object: Node2D = null

func _ready() -> void:
	toggle_grabbing()

func toggle_grabbing() -> void:
	if (!is_grabbing):
		is_grabbing = true
		collision_closed.disabled = true
		collision_open.disabled = false
		%MainSprite.play("grabbing")
		var _closest_junk = _get_closest_junk()
		if _closest_junk != null:
			grab_object(_closest_junk)
	else:
		is_grabbing = false
		collision_closed.disabled = false
		collision_open.disabled = true
		%MainSprite.play("idle")
		if (grabbed_object != null):
			release_object(grabbed_object)

func _on_area_2d_body_entered(_body:Node2D) -> void:
	if is_grabbing && grabbed_object == null && _body.is_in_group("Junk"):
		grab_object(_body)

func _on_area_2d_body_exited(_body:Node2D) -> void:
	if _body.is_in_group("Junk"):
		if !is_grabbing && _body == grabbed_object:
			release_object(_body)

func _get_closest_junk() -> Node2D:
	var bodies = $GrabArea.get_overlapping_bodies()
	var nearest_body: Node2D = null
	var nearest_distance := INF

	for body in bodies:
		if body.is_in_group("Junk"):
			var dist = global_position.distance_to(body.global_position)
			if dist < nearest_distance:
				nearest_distance = dist
				nearest_body = body

	return nearest_body

func grab_object(_body: Node2D) -> void:
	create_joint(_body)
	grabbed_object = _body
	object_grabbed.emit(_body)
	%MainSprite.play("grabbed")

func release_object(_grabbed_body: Node2D):
	if current_joint:
		current_joint.queue_free()  # Remove the joint from the scene
		current_joint = null
		grabbed_object = null
	if is_grabbing:
		%MainSprite.play("grabbing")
	else:
		%MainSprite.play("idle")
	object_released.emit()

func create_joint(_body):
	var joint := PinJoint2D.new()
	joint.position = _body.global_position

	# this is fuckin weird - but the joint needs to be made higher up
	# in an ancestor node that holds both bodies. It also requires
	# node paths instead of direct object references
	var common_parent = get_tree().get_root()
	common_parent.add_child(joint)
	joint.node_a = joint.get_path_to(_body)
	joint.node_b = joint.get_path_to(self)

	joint.bias = 1.0  # max out to make a sticky connection
	joint.softness = 0.0 # no springyness

	# print("joint created: ", joint)
	# print(joint.get_node(joint.node_a))
	# print(joint.get_node(joint.node_b))

	current_joint = joint
