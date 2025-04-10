extends Node2D

@export var max_rope_length := 3000.0
@export var reel_speed := 60.0
var current_rope_length := 0.0

func _process(delta: float) -> void:
	handle_input(delta)

func handle_input(delta):
	if Input.is_action_pressed("reel_down"):
		current_rope_length = min(current_rope_length + reel_speed * delta, max_rope_length)
		print("reel_down: ", current_rope_length)
	elif Input.is_action_pressed("reel_up"):
		current_rope_length = max(current_rope_length - reel_speed * delta, 0)
		print("reel_up: ", current_rope_length)