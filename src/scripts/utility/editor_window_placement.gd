extends Node
# chatgpt helped write this - just saves the last position of the game window when developing. Just make sure
# "Embed game window on next play" option is disabled from the Game tab.
const CONFIG_PATH := "user://dev_window_settings.cfg"

var save_timer: Timer = null

func _ready():
	if not OS.has_feature("editor"):
		return

	# Load saved window position
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		if config.has_section_key("window", "position_x") and config.has_section_key("window", "position_y"):
			var x = config.get_value("window", "position_x", 100)
			var y = config.get_value("window", "position_y", 100)
			DisplayServer.window_set_position(Vector2i(x, y))

	# Create a timer to debounce saves
	save_timer = Timer.new()
	save_timer.one_shot = true
	save_timer.wait_time = 0.5  # half a second after moving
	save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(save_timer)

func _notification(what):
	if not OS.has_feature("editor"):
		return

	if save_timer && what == NOTIFICATION_WM_POSITION_CHANGED:
		if not save_timer.is_stopped():
			save_timer.stop()
		save_timer.start()

func _on_save_timer_timeout():
	_save_window_position()

func _save_window_position():
	var config = ConfigFile.new()
	var pos = DisplayServer.window_get_position()
	config.set_value("window", "position_x", pos.x)
	config.set_value("window", "position_y", pos.y)
	config.save(CONFIG_PATH)
