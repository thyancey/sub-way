extends Control

var dialogue_file = load("res://src/ui/dialogue/dialogue.dialogue")

func _ready() -> void:
	DialogueManager.connect("dialogue_ended", _on_dialogue_ended)
	Global.connect("dialogue_event_sent", _on_dialogue_event_sent)
	Global.connect("dialogue_requested", _on_dialogue_requested)

func _on_dialogue_event_sent(arg1: Variant, arg2: Variant) -> void:
	print("_on_dialogue_event_sent:", arg1, arg2)
	if arg1 == "show_current_mission":
		Global.notify("MISSION", Global.player_data.get_mission_data())

func _on_dialogue_requested(id: String, dialogue_id: String) -> void:
	print("_on_dialogue_requested: ", id, " (", dialogue_id, ")")
	_show_dialogue(id)

func _on_dialogue_ended(arg) -> void:
	print("dialogue ended", arg)
	Global.unpause()

func _show_dialogue(dialogue_id) -> void:
	Global.pause()
	DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_id)
