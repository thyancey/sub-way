extends Control

@export var sweep_length := 22.0
@export var sweep_color := Color(0, 1, 0, 1)
@export var sweep_thickness := 1.0

var sweep_angle := 0.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var arm_vector = Vector2.RIGHT.rotated(sweep_angle) * sweep_length
	draw_line(Vector2.ZERO, arm_vector.round(), sweep_color, sweep_thickness, true)
