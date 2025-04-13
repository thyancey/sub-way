extends Node2D

signal junk_salvaged(junk_data: JunkData)

@onready var main_sprite: AnimatedSprite2D = %MainSprite
@onready var shred_zone: Area2D = %ShredZone
@onready var wake_zone: Area2D = %WakeZone

# fallback duration to play the shred animation, if for some
# reason the thing youre shredding aint there
# var shred_duration := 2.0

var shredding_body: Node2D = null
var start_pos := Vector2.ZERO
var jiggle_pos := 0.5

func _ready() -> void:
	start_pos = self.position

func _process(_delta: float) -> void:
	if shredding_body && shredding_body.hp > 0.0:
		shredding_body.salvage(_delta)
		_jiggle()

func _on_zone_body_entered(_body:Node2D) -> void:
	if shredding_body == null && _body.is_in_group("Junk"):
		_shred_this_junk(_body)

func _shred_this_junk(_junk_body: Node2D) -> void:
	shredding_body = _junk_body
	shredding_body.connect("salvaged", _on_salvaged)
	main_sprite.play("shred")

func _get_next_junk() -> Node2D:
	var bodies = shred_zone.get_overlapping_bodies()
	var nearest_body: Node2D = null
	var nearest_distance := INF

	for body in bodies:
		if body.is_in_group("Junk") && body.hp > 0.0:
			var dist = global_position.distance_to(body.global_position)
			if dist < nearest_distance:
				nearest_distance = dist
				nearest_body = body

	return nearest_body

func _on_salvaged(_salvaged_body: Node2D) -> void:
	_salvage_complete(_salvaged_body)

func _salvage_complete(_salvaged_body: Node2D) -> void:
	print("_salvage_complete")
	if (shredding_body):
		if (shredding_body != _salvaged_body):
			push_error("salvaged junk doesnt match what we thought it was?")
		# score it, make it go away for real
		print("salvaged: ", shredding_body.junk_data.name)
		junk_salvaged.emit(shredding_body.junk_data)
		shredding_body.destroy()
		# gotta jiggle any rested bodies in the chute
		wake_zone.wake_overlapping_bodies()

	var _more_junk = _get_next_junk()
	if _more_junk != null:
		_shred_this_junk(_more_junk)
	else:
		main_sprite.play("idle")

func _jiggle() -> void:
	self.position = start_pos + Vector2(randf_range(-jiggle_pos, jiggle_pos), randf_range(-jiggle_pos, jiggle_pos))