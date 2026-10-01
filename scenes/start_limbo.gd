extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.next_scene_path = "res://scenes/cutscenes/cutscene_context.tscn"

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		LevelTransition.change_scene_to(Globals.next_scene_path)
