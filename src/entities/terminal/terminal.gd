extends StaticBody2D

var is_introduced := false
var player_is_touching := false

func _on_zone_body_entered(body:Node2D) -> void:
	if body.is_in_group("Player"):
		print("_on_zone_body_entered")
		player_is_touching = true

func _on_zone_body_exited(body:Node2D) -> void:
	if body.is_in_group("Player"):
		print("_on_zone_body_exited")
		player_is_touching = false

func _input(_event):
	if Input.is_action_just_pressed("INTERACT") && player_is_touching:
		print("Input received while in area!")
		if is_introduced:
			# attempt to check in mission
			if Global.player_data.check_against_quota():
				Global.request_dialogue("mission_eval")
			else:
				Global.request_dialogue("mission_eval")
		else:
			# await get_tree().create_timer(1).timeout
			is_introduced = true
			Global.request_dialogue("intro")