extends Node2D

@onready var animation: AnimationPlayer = %AnimationPlayer

var orig_origin := Vector2.ZERO
var is_revealed := false

func reveal() -> void:
	if !is_revealed:
		is_revealed = true
		animation.play("flash")
