extends Node2D

@export var color := Color(0.0, 1.0, 1.0, 0.5) # Cyan-ish with some transparency
@export var duration := 6.0
@export var scale_range := Vector2(0.25, 4.0)
@export var final_scale := 4.0
@export var alpha_curve: Curve = null


var time_passed := 0.0

func _ready():
	$Circle.modulate = color
	scale = Vector2.ONE  # Start small

func _process(delta):
	time_passed += delta
	var t = clamp(time_passed / duration, 0.0, 1.0)

	var ease_out_t =  1.0 - pow(1.0 - t, 2)
	# var ease_in_t = t * t

	var s = lerp(scale_range.x, scale_range.y, ease_out_t)
	scale = Vector2(s, s)

	# Animate scale and fade out
	# scale = Vector2.ONE.lerp(Vector2(final_scale, final_scale), t)
	if alpha_curve != null:
		modulate.a = alpha_curve.sample(t)
	else:
		modulate.a = t

	# scale = scale_range.x.lerp(scale_range.y, t)
	# modulate.a = lerp(1.0, 0.0, ease_in_t)
	# print("a", modulate.a)
	

	if t >= 1.0:
		queue_free()
