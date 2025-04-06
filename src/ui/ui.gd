extends CanvasLayer

@onready var depth_label: Label = %DepthLabel

func _ready() -> void:
	Global.connect('updated_depth', on_updated_depth)
	on_updated_depth(Global.depth)

func on_updated_depth(val: int) -> void:
	depth_label.text = "depth: %sm" % val