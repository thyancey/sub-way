extends MenuControl

func _on_button_back_pressed() -> void:
	print("back")
	menu_closed.emit()