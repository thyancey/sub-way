extends CanvasLayer

@onready var depth_label: Label = %DepthLabel
@onready var oxygen_label: Label = %OxygenLabel

func _ready() -> void:
	Global.connect('updated_depth', on_updated_depth)
	on_updated_depth(Global.depth)

	Global.connect('updated_oxygen', on_updated_oxygen)
	on_updated_oxygen(Global.oxygen)


func on_updated_depth(val: int) -> void:
	depth_label.text = "depth: %sm" % val

func on_updated_oxygen(val: float) -> void:
	var clean_value: float = round_to_decimals(val, 2)
	oxygen_label.text = "oxygen: %s" % clean_value

func round_to_decimals(value: float, decimals: int) -> float:
	var multiplier = pow(10.0, decimals)
	return round(value * multiplier) / multiplier