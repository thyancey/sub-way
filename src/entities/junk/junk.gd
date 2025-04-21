extends RigidBody2D

signal salvaged(self_ref: RigidBody2D)

@export var junk_data: JunkData

var hp := 1.0 # taken away when being salvaged
var initial_pos := Vector2.ZERO
var start_pos := Vector2.ZERO
var jiggle_pos := 2
var jiggle_rot := 6

func _ready() -> void:
	self.mass = junk_data.weight
	self.hp = junk_data.hp
	initial_pos = self.global_position

func destroy() -> void:
	hp = 0.0
	queue_free()

func salvage(_delta) -> void:
	if (start_pos == Vector2.ZERO):
		start_pos = self.position

	hp -= _delta	
	self.position = start_pos + Vector2(randf_range(-jiggle_pos, jiggle_pos), randf_range(-jiggle_pos, jiggle_pos))
	self.rotation_degrees += randf_range(-jiggle_rot, jiggle_rot)
	
	if hp < 0.0:
		salvaged.emit(self)

func on_ping(_origin: Vector2) -> void:
	# print("you got me!: ", name, " from ", _origin)
	pass