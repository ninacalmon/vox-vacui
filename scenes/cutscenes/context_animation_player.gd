extends AnimationPlayer

@export var wait_time_to_pass: float = 1.0

var current_index: int = 1

var waiting_for_input: bool = false

var is_playing_animation: bool = false

@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	Globals.next_scene_path = "res://scenes/levels/menus/menu.tscn"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	play("context1")

	is_playing_animation = true
	animation_finished.connect(_on_animation_finished)
	animation_started.connect(_on_animation_started)

	wait_input()

func _input(event: InputEvent) -> void:
	if not waiting_for_input:
		return

	if event.is_action_pressed("confirm"):
		advance_animation()

func advance_animation() -> void:
	wait_input()
	current_index += 1

	if current_index > 5:
		return

	var next_anim := "context%d" % current_index
	play(next_anim)
	is_playing_animation = true

func _on_animation_finished(_anim_name: StringName) -> void:
	is_playing_animation = false
	waiting_for_input = true


func _on_animation_started(anim: String):
	match anim:
		"context1": music.stream = preload("res://music/cutscene_music/msc_cutscene_scene1.wav")
		"context2" : music.stream = preload("res://music/cutscene_music/msc_cutscene_scene2.wav")
		"context3" : music.stream = preload("res://music/cutscene_music/msc_cutscene_scene3.wav")
		"context4" : music.stream = preload("res://music/cutscene_music/msc_cutscene_scene4.mp3")
		"context5" : music.stream = preload("res://music/cutscene_music/msc_cutscene_scene5.mp3")
	music.stop()
	music.play()


func wait_input():
	waiting_for_input = false
	await get_tree().create_timer(wait_time_to_pass).timeout
	waiting_for_input = true
