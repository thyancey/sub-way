extends CPUParticles2D

func _ready():
	# Start the particle system
	emitting = true
	# Set a timer to queue_free when emission is done
	await get_tree().create_timer(lifetime + 0.1).timeout
	queue_free()
