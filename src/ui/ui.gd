extends CanvasLayer

@onready var oxygen_gauge: Control = %OxygenGauge
@onready var depth_gauge: Control = %DepthGauge
@onready var rope_length_gauge: Control = %RopeGauge
@onready var component_label: Label = %ComponentLabel

func _ready() -> void:
	Global.connect('updated_depth', on_updated_depth)
	on_updated_depth(Global.depth)

	Global.connect('updated_oxygen', on_updated_oxygen)
	on_updated_oxygen(Global.oxygen)

	Global.connect('updated_rope_length', on_updated_rope_length)
	on_updated_rope_length(Global.rope_length)

	Global.connect('updated_active_component_name', on_updated_active_component_name)
	on_updated_active_component_name(Global.active_component_name)

	oxygen_gauge.setData("oxygen", Vector2(0.0, Global.max_oxygen), Global.oxygen, true)
	depth_gauge.setData("depth", Vector2(0.0, 400.0), Global.depth)
	rope_length_gauge.setData("rope length", Vector2(0.0, 400.0), Global.rope_length)

func on_updated_depth(value: int) -> void:
	depth_gauge.value = value

func on_updated_oxygen(value: float) -> void:
	oxygen_gauge.value = value

func on_updated_rope_length(value: float) -> void:
	rope_length_gauge.value = value


func on_updated_active_component_name(value: String) -> void:
	component_label.text = value
