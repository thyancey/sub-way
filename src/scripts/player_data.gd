extends Object
class_name PlayerData

signal updated_money(val: int)
signal updated_depth(val: int)
signal updated_oxygen(val: float)
signal updated_active_component_name(val: String)
signal updated_rope_length(val: float)
signal updated_mission_level(val: int)

var max_oxygen := 100.0
var rope_range := Vector2(1.0, 200.0)
var ping_range := 200.0

var mission_level := -1:
	get:
		return mission_level
	set(value):
		if mission_level != value:
			mission_level = value
			updated_mission_level.emit(mission_level)

var active_component_name := "???":
	get:
		return active_component_name
	set(value):
		if active_component_name != value:
			active_component_name = value
			updated_active_component_name.emit(active_component_name)

var money := 0:
	get:
		return money
	set(value):
		if money != value:
			money = value
			updated_money.emit(money)
			if _check_against_quota():
				mission_level += 1

var depth := 0:
	get:
		return depth
	set(value):
		if depth != value:
			depth = value
			updated_depth.emit(depth)

var oxygen := max_oxygen:
	get:
		return oxygen
	set(value):
		# var new_value: float = round_to_decimals(clamp(value, 0.0, 1.0), 2)
		# print("new_value: ", new_value)
		var new_value: float = clamp(value, 0.0, max_oxygen)
		if oxygen != new_value:
			oxygen = new_value
			updated_oxygen.emit(new_value)
			
var rope_length := rope_range.x:
	get:
		return rope_length
	set(value):
		if rope_length != value:
			rope_length = value
			updated_rope_length.emit(value)

func round_to_decimals(value: float, decimals: int) -> float:
	var multiplier = pow(10.0, decimals)
	return round(value * multiplier) / multiplier

func reset() -> void:
	self.oxygen = max_oxygen
	self.money = 0
	self.depth = 0
	self.rope_length = rope_range.x
	# self.active_component_name = "???"
	self.mission_level = 0

func get_mission_data(_mission_idx: int = -1) -> Dictionary:
	if _mission_idx == -1:
		_mission_idx = mission_level

	print("get_mission_data ", _mission_idx)
	if _mission_idx >= 0 and _mission_idx < GameData.MISSIONS.size():
		return GameData.MISSIONS[_mission_idx]
	else:
		push_error("no goal for mission idx: ", _mission_idx)
		return {}

	
func _check_against_quota() -> bool:
	if money > get_mission_data(mission_level).goal.money:
		return true
	else:
		return false