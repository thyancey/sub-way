extends Control

@onready var portrait_texture: TextureRect = %TextureRect

# in editor, should position at 0, 0
var portraits: Dictionary = {
	"default": {
		"texture":  "res://src/ui/dialogue/portrait/portrait-player.png",
	},
	"terminal": {
		"texture":  "res://src/ui/dialogue/portrait/portrait-terminal.png",
	}
} 

# will be same keys as portraits
var textures = {}

func _ready() -> void:
	for key in portraits.keys():
		textures[key] = load(portraits[key].texture)

func set_character(portrait_id: String = "default") -> void:
	if !portraits.has(portrait_id):
		portrait_id = "default"
	portrait_texture.texture = textures[portrait_id]
