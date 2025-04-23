extends MenuControl

func _on_button_start_pressed() -> void:
	scene_loaded.emit("game_main", null)

func _on_button_back_pressed() -> void:
	menu_closed.emit()