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

# hack to avoid warning on ununsed symbols
func _nothing() -> void:
	_dump_signals([menu_loaded, menu_closed, scene_loaded, command_sent])
func _dump_signals(_var_args: Array) -> void:
	pass