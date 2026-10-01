extends Control

@export var pause_color_rect: ColorRect

@export var continue_button: Button

@export var exit_button: Button

var is_paused: bool = false

func _ready() -> void:
	pause_color_rect.hide()
	continue_button.pressed.connect(_on_continue_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if Globals.is_showing_confirmation or Globals.is_cutscene:
			return

		get_viewport().set_input_as_handled()

		if is_paused:
			unpause()
		else:
			pause()

func pause():
	MusicManager.set_pause_music(true)
	is_paused = true
	pause_color_rect.visible = true
	get_tree().paused = true
	continue_button.grab_focus()

func unpause():
	MusicManager.set_pause_music(false)
	is_paused = false
	pause_color_rect.visible = false
	get_tree().paused = false
	await tween_time_scale()

func tween_time_scale():
	Engine.time_scale = 0.2
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.4)
	await tween.finished

func _on_continue_button_pressed():
	get_viewport().set_input_as_handled()
	unpause()

func _on_exit_button_pressed():
	get_viewport().set_input_as_handled()
	unpause()
	LevelTransition.change_scene_to("res://scenes/levels/menus/menu.tscn")
