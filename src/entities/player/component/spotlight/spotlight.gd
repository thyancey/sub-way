extends Ship_Component

@export var mouse_aim := false
@onready var spotlight: PointLight2D = %Spotlight
@onready var main_sprite: AnimatedSprite2D = %MainSprite
@onready var light_sprite: AnimatedSprite2D = %LightSprite

var aim_direction := Vector2.ZERO
var light_active := false
var realtime := true

func _ready() -> void:
	_render_light(light_active)

func _process(_delta: float) -> void:
	if realtime || is_active:
		if mouse_aim:
			aim_direction = (get_global_mouse_position() - global_position).normalized()
			graphic.rotation = aim_direction.angle()
			spotlight.rotation = aim_direction.angle()

func _input(_delta) -> void:
	if realtime:
		if Input.is_action_pressed("LIGHT") && !light_active:
			light_active = true
			_render_light(light_active)
		elif !Input.is_action_pressed("LIGHT") && light_active:
			light_active = false
			_render_light(light_active)
	elif is_active:
		if Input.is_action_just_pressed("COMPONENT_ACTIVATE"):
			light_active = !light_active
			_render_light(light_active)

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
	light_active = _val
	_render_light(light_active)
