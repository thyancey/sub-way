extends CPUParticles2D

func _ready():
	# Start the particle system
	emitting = true
	# Set a timer to queue_free when emission is done
	var _cleanup_delay := lifetime + lifetime * lifetime_randomness + 0.5
	await get_tree().create_timer(_cleanup_delay).timeout
	queue_free()
