extends MenuControl

@onready var button_quit: Control = %Button_Quit

func _ready() -> void:
	if OS.get_name() == "Web":
		# quit just locks up page on the web
		button_quit.hide()

	# if [
	# 		Enums.FinishReason.NONE,
	# 		Enums.FinishReason.WIN,
	# 		Enums.FinishReason.LOSE,
	# 		Enums.FinishReason.DEAD,
	# 		Enums.FinishReason.QUIT
	# 	].has(menu_param.reason):
	# 		print("menu_main loaded with reason: ", menu_param.reason)
	# else:
	# 	print("menu_main loaded with no reason")

func _on_button_start_pressed() -> void:
	scene_loaded.emit("game_main", null)

func _on_button_settings_pressed() -> void:
	menu_loaded.emit("menu_settings")

func _on_button_quit_pressed() -> void:
	get_tree().quit()
