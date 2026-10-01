class_name CutsceneControl
extends Control

@export var video_stream_player: VideoStreamPlayer

@export var  animation_player: AnimationPlayer

@export var last_anim_name: String

@export var hold_duration: float = 1

var hold_time: float = 0.0

var decay_speed: = 2

@onready var skip_progress: TextureProgressBar = $SkipProgress

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	InputGuide.clear_guides()
	if last_anim_name:
		InputGuide.show_guide(InputGuide.ActionType.NEXT)
	InputGuide.show_guide(InputGuide.ActionType.SKIP)
	setup_bar()

	if video_stream_player:
		video_stream_player.finished.connect(finish_cutscene)
		video_stream_player.play()

	elif animation_player:
		animation_player.animation_finished.connect(finish_cutscene)

func _process(delta: float) -> void:
	var holding: bool = Input.is_action_pressed("return")

	if holding:
		skip_progress.visible = true
		hold_time += delta
	else:
		hold_time -= delta * decay_speed

		if hold_time <= 0.01:
			skip_progress.visible = false

	hold_time = clamp(hold_time, 0.0, hold_duration)

	skip_progress.value = hold_time

	if hold_time >= hold_duration:
		finish_cutscene(null, true)

func setup_bar():
	skip_progress.max_value = hold_duration
	skip_progress.value = hold_time

func finish_cutscene(_anim = null, bypass: bool = false):
	if animation_player:
		if _anim == last_anim_name:
			bypass = true
		if not bypass:
			return
	if video_stream_player:
		video_stream_player.stop()
	LevelTransition.change_scene_to(Globals.next_scene_path)
