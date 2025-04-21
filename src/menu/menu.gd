extends Control
class_name MenuControl

var menu_param: Variant = null
signal command_sent(_command: String)
signal scene_loaded(_scene_key: String, _detail: Variant)
signal menu_loaded(_menu_key: String)
signal menu_closed()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		menu_closed.emit()
