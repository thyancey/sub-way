extends Creature

@export var swim_speed: float = 40.0
@export var turn_interval: float = 6.0
@export var turn_interval_rando := 3.0
@export var wave_amplitude: float = 10.0
@export var wave_frequency: float = 1.5

@onready var MainSprite: AnimatedSprite2D = %MainSprite

var direction := Vector2.LEFT
var wave_timer := 0.0
var turn_timer := 0.0
var base_y := 0.0
var wave_offset := 0.0
var next_turn := 0.0

func set_next_turn() -> void:
	next_turn = turn_interval + randf() * turn_interval_rando


func _ready() -> void:
	base_y = position.y
	wave_offset = randf() * TAU  # random phase for unique swim
	# Pick random initial direction
	direction = Vector2.LEFT if randf() > 0.5 else Vector2.RIGHT
	look_at(position + direction)
	set_next_turn()
	MainSprite.play('swim')

func _physics_process(delta: float) -> void:
	turn_timer += delta
	wave_timer += delta

	if turn_timer > next_turn:
		set_next_turn()
		# Turn around
		direction *= -1
		look_at(position + direction)
		turn_timer = 0.0
		# Optionally reset wave_offset so they don't just mirror
		wave_offset = randf() * TAU

	# Sinusoidal vertical offset
	var wave_y = sin(wave_timer * wave_frequency + wave_offset) * wave_amplitude
	var offset = Vector2(direction.x * swim_speed * delta, wave_y * delta)

	position += offset
	
	if direction == Vector2.LEFT:
		MainSprite.flip_v = true
	else:
		MainSprite.flip_v = false

func hit() -> void:
	print("HIT")
	queue_free()