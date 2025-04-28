extends StaticBody2D

var is_introduced := false

func _on_zone_body_entered(body:Node2D) -> void:
	if body.is_in_group("Player"):
		print("body")
		if is_introduced:
			Global.request_dialogue("terminal_touch")
		else:
			await get_tree().create_timer(1).timeout
			is_introduced = true
			Global.request_dialogue("intro")



