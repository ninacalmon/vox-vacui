class_name TextsControl
extends Control

signal count_finished

@export var button: Button

var min_tween_duration: float = 1

var max_tween_duration: float = 6

var value: int = 0

var last_int: int = -1

var can_progress: bool

@onready var counter: RichTextLabel = $Counter

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	EventBus.resources_used.connect(_on_resources_used)
	can_progress = Globals.resources_gathered >= Globals.resources_needed
	button.pressed.connect(_on_button_pressed)

	button.disabled = true
	button.hide()

	counter.text = "[b]%d[/b]/%d" %[0, Globals.resources_needed]
	await animate_number()
	count_finished.emit()
	await get_tree().create_timer(2).timeout
	show_button()

func animate_number():
	var tween_time: float
	if can_progress:
		tween_time = min(Globals.resources_gathered/10.0, max_tween_duration)
	else: tween_time = max(Globals.resources_gathered/10.0, min_tween_duration)

	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_update_text, 0, Globals.resources_gathered, tween_time)
	await tween.finished

func show_button():
	if can_progress:
		button.text = "Continuar...-->"
	else: button.text = "<--...Tentar novamente"

	button.disabled = false
	button.show()
	flash(button)

func flash(what: Control):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(what, "self_modulate", Color(0, 0, 0, 1), 0.02)
	tween.tween_property(what, "self_modulate", Color(10, 10, 10, 10), 0.05)
	tween.tween_property(what, "self_modulate", Color(1, 1, 1, 1), 0.2)

func _update_text(v):
	var current_value = int(v)
	counter.text = "[b]%d[/b]/%d" %[current_value, Globals.resources_needed]

	if current_value != last_int:
		last_int = current_value
		audio_stream_player.play()
		audio_stream_player.pitch_scale += 0.01

func _on_button_pressed():
	if can_progress:
		Globals.level += 1
		EventBus.level_pass.emit()
		LevelTransition.change_scene_to("res://scenes/levels/space_levels/Level%d.tscn" %Globals.level)

	else:
		LevelTransition.change_scene_to("res://scenes/levels/space_levels/Level%d.tscn" %Globals.level)

func _on_resources_used():
	_update_text(Globals.resources_gathered)
