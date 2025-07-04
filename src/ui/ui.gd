extends CanvasLayer

@onready var oxygen_gauge: Control = %OxygenGauge
@onready var rope_length_gauge: Control = %Gauge_Vertical_R
@onready var depth_gauge: Control = %Gauge_Vertical_L
@onready var component_widget: Control = %ComponentWidget
@onready var junk_widget: Control = %JunkWidget
@onready var money_widget: Control = %MoneyWidget
@onready var goal_widget: Control = %GoalWidget
@onready var level_widget: Control = %LevelWidget
@onready var notification_widget: Control = %NotificationWidget
@onready var mission_widget: Control = %MissionWidget
@onready var radar: Control = %Radar
@onready var ui_wrapper: Control = %Wrapper

@export var hud_transparency := 0.8

func _ready() -> void:
	_set_hud_transparency(hud_transparency)

	junk_widget.hide()
	Global.connect("notified", _on_global_notified)

	Global.player_data.connect('updated_mission_level', _on_updated_mission_level)
	_on_updated_mission_level(Global.player_data.mission_level)

	Global.player_data.connect('updated_money', _on_updated_money)
	_on_updated_money(Global.player_data.money)

	Global.player_data.connect('updated_depth', _on_updated_depth)
	_on_updated_depth(Global.player_data.depth)

	Global.player_data.connect('updated_oxygen', _on_updated_oxygen)
	_on_updated_oxygen(Global.player_data.oxygen)

	Global.player_data.connect('updated_rope_length', _on_updated_rope_length)
	_on_updated_rope_length(Global.player_data.rope_length)

	Global.player_data.connect('updated_active_component_name', _on_updated_active_component_name)
	_on_updated_active_component_name(Global.player_data.active_component_name)

	oxygen_gauge.setData("oxygen", Vector2(0.0, Global.player_data.max_oxygen), Global.player_data.oxygen, true)
	depth_gauge.setData("depth", Vector2(0.0, 400.0), Global.player_data.depth)
	rope_length_gauge.setData("rope", Global.player_data.rope_range, Global.player_data.rope_length)

func _set_hud_transparency(_value: float) -> void:
	ui_wrapper.modulate.a = _value

func _on_updated_money(_value: int) -> void:
	money_widget.label_value = str("$", _value)

func _on_updated_mission_level(_value: int) -> void:
	if (_value > -1):
		var _md = Global.player_data.get_mission_data(_value)
		goal_widget.label_value = str("$", _md.goal.money)
		level_widget.label_value = _md.message
		mission_widget.notify(_md.message)

func _on_updated_depth(_value: int) -> void:
	depth_gauge.value = _value

func _on_updated_oxygen(_value: float) -> void:
	oxygen_gauge.value = _value

func _on_updated_rope_length(_value: float) -> void:
	rope_length_gauge.value = _value

func _on_updated_active_component_name(_value: String) -> void:
	component_widget.label_value = _value

func _on_global_notified(_type: String, _payload: Variant) -> void:
	if _type == 'SALVAGE':
		notification_widget.notify("%s: $%d" % [ (_payload as JunkData).name, (_payload as JunkData).value ])
	elif _type == 'GRAB':
		if (_payload == null):
			junk_widget.hide()
		elif (_payload.is_in_group("Junk")):
			junk_widget.show()
			junk_widget.label_name = (_payload.junk_data as JunkData).name
			junk_widget.label_value = str((_payload.junk_data as JunkData).value)
			junk_widget.color_name = _payload.junk_data.color
