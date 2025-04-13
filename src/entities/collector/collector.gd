extends Node2D

signal junk_salvaged(_name: String, _value: int)

func _on_zone_body_entered(_body:Node2D) -> void:
	if _body.is_in_group("Junk"):
		junk_salvaged.emit(_body.junk_name, _body.junk_value)
		_body.salvage()
