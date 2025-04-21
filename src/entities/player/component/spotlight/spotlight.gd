extends Ship_Component

@export var mouse_aim := false
@onready var spotlight: PointLight2D = %Spotlight
@onready var main_sprite: AnimatedSprite2D = %MainSprite
@onready var light_sprite: AnimatedSprite2D = %LightSprite

var aim_direction := Vector2.ZERO
var _light_on := false

func _ready() -> void:
	_render_light(_light_on)

func _process(_delta: float) -> void:
	if is_active:
		if mouse_aim:
			aim_direction = (get_global_mouse_position() - global_position).normalized()
			graphic.rotation = aim_direction.angle()
			spotlight.rotation = aim_direction.angle()

func _input(_delta) -> void:
	if is_active && Input.is_action_just_pressed("COMPONENT_ACTIVATE"):
		_light_on = !_light_on
		_render_light(_light_on)

func _render_light(_val: bool) -> void:
	if _val:
		_val = true
		main_sprite.play("on")
		light_sprite.show()
	else:
		_val = false
		main_sprite.play("off")
		light_sprite.hide()

	spotlight.enabled = _val


func _on_active_changed(_val: bool):
	super._on_active_changed(_val)
	_light_on = _val
	_render_light(_light_on)
