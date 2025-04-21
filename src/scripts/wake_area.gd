extends Area2D
# Wakes up physics bodies it touches - useful when removing a RigidBody2D
# from a settled pile of other RigidBodies

@export var debug := false

func _ready():
	monitoring = true

func wake_overlapping_bodies():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody2D:
			if body.sleeping:
				body.sleeping = false
				if debug:
					print("Woke up:", body.name)
