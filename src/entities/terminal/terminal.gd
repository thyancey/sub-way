extends StaticBody2D

func _on_zone_body_entered(body:Node2D) -> void:
	if body.is_in_group("Player"):
		print("body")
		Global.request_dialogue("terminal_touch")
