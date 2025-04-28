extends MenuControl

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("PAUSE"):
		menu_closed.emit()

func _on_button_continue_pressed() -> void:
	print("continue")
	menu_closed.emit()

func _on_button_settings_pressed() -> void:
	print("settings")
	menu_loaded.emit("menu_settings")

func _on_button_quit_pressed() -> void:
	print("quit")
	menu_loaded.emit("menu_main")
