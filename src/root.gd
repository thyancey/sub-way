extends Node2D

@onready var darkness: CanvasModulate = %Darkness

func _ready() -> void:
	Global.connect('updated_darkness', on_updated_darkness)
	on_updated_darkness(Global.calc_darkness(Global.depth))

func on_updated_darkness(darkness_percent: float) -> void:
	darkness.color = Color(1, 1, 1).lerp(Color(0, 0, 0), darkness_percent)
