extends Node2D

@export var surface_darkness: Color = Color(1, 1, 1)
@export var min_darkness: Color = Color(1, 1, 1)
@export var max_darkness: Color = Color(0, 0, 0)
@export var blur_scale := Vector2(1.0, 0.5)
# min/max depth for applying the darkness effect
@export var darkness_depth_range := Vector2(50.0, 300.0)

@onready var darkness: CanvasModulate = %Darkness
@onready var blur_effect: ColorRect = %BlurEffect

var blur_material: ShaderMaterial
var blur_range := Vector2(0.0, Global.player_data.max_oxygen)

func _ready() -> void:
	Global.player_data.reset()

	Global.player_data.connect('updated_depth', _on_updated_depth)
	blur_material = %BlurEffect.material
	_on_updated_depth(calc_darkness(Global.player_data.depth))

func _on_updated_depth(_depth: float) -> void:
	if _depth < darkness_depth_range.x:
		#ideally lights are off while within this depth
		var _surface_percent = 1 - (darkness_depth_range.x - _depth) / darkness_depth_range.x
		darkness.color = lerp(surface_darkness, min_darkness, _surface_percent)
		_update_blur(0)
	else:
		var _darkness_percent = calc_darkness(_depth)
		darkness.color = lerp(min_darkness, max_darkness, _darkness_percent)
		_update_blur(_darkness_percent)

func _update_blur(_blur_percent: float) -> void:
	var _blur: float = lerp(blur_scale.x, blur_scale.y, _blur_percent)
	if blur_material is ShaderMaterial:
		blur_material.set_shader_parameter("colorCorrection", _blur)

func calc_darkness(_depth) -> float:
	var darkness_percent: float = 0.0
	if _depth < darkness_depth_range.x:
		darkness_percent = 0.0
	elif _depth > darkness_depth_range.y:
		darkness_percent = 1.0
	else:
		darkness_percent = (_depth - darkness_depth_range.x) / (darkness_depth_range.y - darkness_depth_range.x)

	return darkness_percent
