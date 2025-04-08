extends CanvasLayer

@onready var oxygen_gauge: Control = %OxygenGauge
@onready var depth_gauge: Control = %DepthGauge

func _ready() -> void:
	Global.connect('updated_depth', on_updated_depth)
	on_updated_depth(Global.depth)

	Global.connect('updated_oxygen', on_updated_oxygen)
	on_updated_oxygen(Global.oxygen)

	oxygen_gauge.setData("oxygen", Vector2(0.0, Global.max_oxygen), Global.oxygen, true)
	depth_gauge.setData("depth", Vector2(0.0, 400.0), Global.depth)

func on_updated_depth(value: int) -> void:
	depth_gauge.value = value

func on_updated_oxygen(value: float) -> void:
	oxygen_gauge.value = value
