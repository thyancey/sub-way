extends Node2D

@onready var darkness: CanvasModulate = %Darkness
@onready var blur_effect: ColorRect = %BlurEffect

var blur_material: ShaderMaterial

var blur_range := Vector2(0.0, Global.max_oxygen)
var blur_scale := Vector2(1.0, 0.25)

func _ready() -> void:
	blur_material = %BlurEffect.material

	Global.connect('updated_darkness', on_updated_darkness)
	on_updated_darkness(Global.calc_darkness(Global.depth))

	# for now, blur works fine with depth
	# Global.connect('updated_oxygen', on_updated_oxygen)
	# on_updated_oxygen(Global.oxygen)
	
func on_updated_darkness(darkness_percent: float) -> void:
	darkness.color = lerp(Color(1, 1, 1), Color(0, 0, 0), darkness_percent)
	_update_blur(darkness_percent)
	
func on_updated_oxygen(_oxygen: float) -> void:
	_update_blur(_calc_blur(_oxygen))

func _update_blur(_blur_percent: float) -> void:
	var blur: float = lerp(blur_scale.x, blur_scale.y, _blur_percent)
	if blur_material is ShaderMaterial:
		blur_material.set_shader_parameter("colorCorrection", blur)

func _calc_blur(_oxygen: float) -> float:
	var blur_percent: float = clamp(_oxygen, blur_range.x, blur_range.y)
	if _oxygen < blur_range.x:
		blur_percent = 0.0
	elif _oxygen > blur_range.y:
		blur_percent = 1.0
	else:
		blur_percent = (_oxygen - blur_range.x) / (blur_range.y - blur_range.x)

	#invert it, since less oxygen = more blurry
	blur_percent = clamp(1.0 - blur_percent, 0.0, 1.0)
	return blur_percent
