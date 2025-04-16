extends CharacterBody2D
class_name Creature

func on_ping(_origin: Vector2) -> void:
	print("you got me!: ", name, " from ", _origin)

func hit() -> void:
	pass