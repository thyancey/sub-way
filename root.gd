extends Node2D

var scene_map: Dictionary = {
	"menu_main": preload("res://src/menu/menu_main.tscn"),
	"menu_pause": preload("res://src/menu/menu_pause.tscn"),
	"menu_settings": preload("res://src/menu/menu_settings.tscn"),
	"game_main": preload("res://src/game.tscn")
}

@onready var scene_container: Node2D = %Scene
@onready var menu_container: CanvasLayer = %Menu

var active_menu: MenuControl = null
var game_scene: Node2D = null
var menu_stack: Array[String] = []

func _ready() -> void:
	_on_menu_loaded("menu_main")

func _load_menu(_packed_scene: PackedScene, _custom_param: Variant = null) -> void:
	if (active_menu):
		active_menu.queue_free()
		active_menu = null
	else:
		menu_container.show()

	active_menu = _packed_scene.instantiate()
	active_menu.connect("menu_loaded", _on_menu_loaded)
	active_menu.connect("menu_closed", _on_menu_closed)
	active_menu.connect("command_sent", _on_command_sent)
	active_menu.connect("scene_loaded", _on_scene_loaded)
	
	active_menu.menu_param = _custom_param
	menu_container.add_child(active_menu)

func _close_out_menus() -> void:
	menu_stack = []
	if active_menu:
		active_menu.queue_free()
		active_menu = null

	menu_container.hide()

	if game_scene:
		game_scene.on_menus_closed()

func _teardown_game() -> void:
	game_scene.cleanup()
	scene_container.remove_child(game_scene)
	game_scene.queue_free()

func _on_scene_loaded(_scene_key: String, _detail: Variant) -> void:
	_close_out_menus()
	
	if game_scene:
		_teardown_game()

	var _packed: PackedScene = scene_map[_scene_key]
	game_scene = _packed.instantiate()
	game_scene.connect("menu_loaded", _on_menu_loaded)
	
	scene_container.add_child(game_scene)

func _on_menu_loaded(_menu_key: String, _menu_param: Variant = null) -> void:
	if !scene_map.has(_menu_key):
		push_error("Invalid _menu_key: ", _menu_key)
	else:
		if _menu_key == "main":
			menu_stack = ["main"]
		elif menu_stack.size() > 0 && menu_stack[menu_stack.size() - 1] == _menu_key:
			# we poppin a menu here
			pass
		else:
			menu_stack.push_back(_menu_key)
		_load_menu(scene_map[_menu_key], _menu_param)

func _on_menu_closed() -> void:
	if menu_stack == ["main"]:
		return
	
	menu_stack.pop_back()
	
	if menu_stack.size() > 0:
		_on_menu_loaded(menu_stack[menu_stack.size() - 1])
	else:
		_close_out_menus()

func _on_command_sent(_command: String) -> void:
	if _command == "game_quit":
		if game_scene:
			game_scene.queue_free()
			game_scene = null
