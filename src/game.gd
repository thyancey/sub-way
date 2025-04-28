extends Node2D

signal menu_loaded(_menu_key: String, _menu_param: Variant)

@onready var ui: CanvasLayer = %UI

func _ready() -> void:
	Global.player_data.reset()
	for collector in get_tree().get_nodes_in_group("Collector"):
		collector.junk_salvaged.connect(_on_junk_salvaged)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("PAUSE"):
		_on_game_pause()

func _on_game_pause() -> void:
	print("_on_game_pause()")
	Global.pause()
	ui.hide()
	menu_loaded.emit("menu_pause");

func on_menus_closed() -> void:
	print("on_menus_closed()")
	Global.unpause()
	ui.show()

func cleanup() -> void:
	print("Game.cleanup()")
	
func _on_junk_salvaged(_pos: Vector2, _junk_data: JunkData) -> void:
	# print("SALVAGED: %s: $%d" % [_junk_data.name, _junk_data.value])
	Global.notify("SALVAGE", _junk_data)
	Global.spawn_particle("salvage", _pos, { "color": _junk_data.color })
	Global.player_data.money += _junk_data.value
