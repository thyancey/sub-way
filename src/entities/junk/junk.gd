extends RigidBody2D

@export var junk_data: JunkData


func _ready() -> void:
	self.mass = junk_data.weight

func salvage() -> void:
	queue_free()