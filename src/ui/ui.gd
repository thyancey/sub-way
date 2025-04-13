extends CanvasLayer

@onready var oxygen_gauge: Control = %OxygenGauge
@onready var depth_gauge: Control = %DepthGauge
@onready var rope_length_gauge: Control = %RopeGauge
@onready var component_label: Label = %ComponentLabel

func _ready() -> void:
	Global.player_data.connect('updated_depth', on_updated_depth)
	on_updated_depth(Global.player_data.depth)

	Global.player_data.connect('updated_oxygen', on_updated_oxygen)
	on_updated_oxygen(Global.player_data.oxygen)

	Global.player_data.connect('updated_rope_length', on_updated_rope_length)
	on_updated_rope_length(Global.player_data.rope_length)

	Global.player_data.connect('updated_active_component_name', on_updated_active_component_name)
	on_updated_active_component_name(Global.player_data.active_component_name)

	oxygen_gauge.setData("oxygen", Vector2(0.0, Global.player_data.max_oxygen), Global.player_data.oxygen, true)
	depth_gauge.setData("depth", Vector2(0.0, 400.0), Global.player_data.depth)
	rope_length_gauge.setData("rope length", Vector2(0.0, 400.0), Global.player_data.rope_length)

func on_updated_depth(value: int) -> void:
	depth_gauge.value = value

func on_updated_oxygen(value: float) -> void:
	oxygen_gauge.value = value

func on_updated_rope_length(value: float) -> void:
	rope_length_gauge.value = value


func on_updated_active_component_name(value: String) -> void:
	component_label.text = value
