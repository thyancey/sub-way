extends CharacterBody2D
class_name Creature

func on_ping(_distance: float) -> void:
	print("you got me! ", name, " : ", _distance)
	Global.spawn_ping_circle(global_position, Color(0, 221, 255, 45))

func hit() -> void:
	pass