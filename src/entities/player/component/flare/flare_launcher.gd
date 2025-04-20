extends Ship_Component

func _input(_delta: InputEvent) -> void:
	if is_active && Input.is_action_just_pressed("ACTIVATE_COMPONENT"):
		_launch_flare()

func _launch_flare():
	pass