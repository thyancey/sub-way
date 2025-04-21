extends Control

@export var text := "???"

func _ready() -> void:
	notify(text)
	
func notify(_new_text: String) -> void:
	text = _new_text
	%Label.text = text
	%AnimationPlayer.play('in')
	%AnimationPlayer.seek(0.0, true)