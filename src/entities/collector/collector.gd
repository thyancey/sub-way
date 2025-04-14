extends Node2D

signal junk_salvaged(_pos: Vector2, _junk_data: JunkData)

@onready var main_sprite: AnimatedSprite2D = %MainSprite
@onready var shred_zone: Area2D = %ShredZone
@onready var wake_zone: Area2D = %WakeZone


# fallback duration to play the shred animation, if for some
# reason the thing youre shredding aint there
# var shred_duration := 2.0

var salvage_bodies: Array[Node2D] = []
var start_pos := Vector2.ZERO
var jiggle_pos := 0.5

func _ready() -> void:
	start_pos = self.position
	salvage_bodies = []

func _process(_delta: float) -> void:
	if salvage_bodies.size() > 0:
		_jiggle()
		for _junk in salvage_bodies:
			if _junk && _junk.hp > 0.0:
				_junk.salvage(_delta)

func _on_zone_body_entered(_body:Node2D) -> void:
	_try_to_shred_this(_body)

func _try_to_shred_this(_body: Node2D) -> void:
	if _body.is_in_group("Junk") && !salvage_bodies.has(_body):
		salvage_bodies.append(_body)
		_body.connect("salvaged", _on_salvaged)
		main_sprite.play("shred")

# gotta jiggle any rested bodies in the chute after others are deleted
func _get_frozen_junk() -> Array[Node2D]:
	wake_zone.wake_overlapping_bodies()
	var _bodies = shred_zone.get_overlapping_bodies()
	var _frozen_junk: Array[Node2D] = []

	for _body in _bodies:
		if _body.is_in_group("Junk") && _body.hp > 0.0 && !salvage_bodies.has(_body):
			_frozen_junk.append(_body)
	return _frozen_junk

func _on_salvaged(_salvaged_body: Node2D) -> void:
	_salvage_complete(_salvaged_body)

func _salvage_complete(_salvaged_body: Node2D) -> void:
	print("_salvage_complete")
	if !salvage_bodies.has(_salvaged_body):
		push_error("salvage_bodies doesnt contain the junk that was salvaged!")
	else:
		# score it, make it go away for real
		print("salvaged: ", _salvaged_body.junk_data.name)
		junk_salvaged.emit(_salvaged_body.position, _salvaged_body.junk_data)
		salvage_bodies.erase(_salvaged_body)
		_salvaged_body.destroy()

	var _frozen_junk = _get_frozen_junk()
	if _frozen_junk.size() > 0:
		for _junk in _frozen_junk:
			_try_to_shred_this(_junk)

	print(">> COMPLETE, should I keep shreddin? ", salvage_bodies.size())
	if salvage_bodies.size() == 0:
		main_sprite.play("idle")

func _jiggle() -> void:
	self.position = start_pos + Vector2(randf_range(-jiggle_pos, jiggle_pos), randf_range(-jiggle_pos, jiggle_pos))