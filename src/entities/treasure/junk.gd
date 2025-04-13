extends RigidBody2D

@export var junk_value := 1500
@export var junk_name := "ruby"

func salvage() -> void:
	queue_free()