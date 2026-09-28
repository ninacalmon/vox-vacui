class_name CutsceneCamera
extends Camera2D

const default_zoom: Vector2 = Vector2(1, 1)

@export var zoom_speed: float = 0.2
@export var zoom_smoothness: float = 3.0

@export_subgroup("Start Cutscene")
@export var full_view_zoom: Vector2 = Vector2(0.45, 0.45)
@export var full_view_pos: Vector2 = Vector2(0.0, -500)
@export var full_view_duration: float = 1.0
@export var zoom_in_speed: float = 4.0
@export var deactivate_cutscene: bool = false

var min_zoom = 0.1
var max_zoom = 4.5


@onready var zoom_in_cutscene_sfx: AudioStreamPlayer = $"../SFX/ZoomInCutsceneSFX"


func _ready():
	if not deactivate_cutscene:
		start_cutscene()
	else:
		Globals.is_cutscene = false


func start_cutscene():
	EventBus.cutscene_on.emit()
	zoom = full_view_zoom
	position += full_view_pos
	await get_tree().create_timer(full_view_duration).timeout
	SFXManager.play_sound(zoom_in_cutscene_sfx)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(self, "zoom", default_zoom, zoom_in_speed)
	tween.parallel().tween_property(self, "position", Vector2(0, 0), zoom_in_speed)
	await tween.finished
	print(zoom)
	EventBus.cutscene_off.emit()


#func _process(delta):
	#if Globals.is_cutscene:
		#return
#
	#zoom = zoom.lerp(target_zoom, zoom_smoothness * delta)
#
	### Controller logic vvvvvv
	#if Input.is_action_pressed("shoulderL"):
		#simulate_zoom_out_input()
	#if Input.is_action_pressed("shoulderR"):
		#simulate_zoom_in_input()
	#if Input.is_action_pressed("shoulderR") and Input.is_action_pressed("shoulderL"):
		#simulate_camera_reset_input()

#func simulate_zoom_out_input():
	#var zoom_out_camera_event = InputEventAction.new()
	#zoom_out_camera_event.action = "scroll_down"
	#zoom_out_camera_event.pressed = true
	#Input.parse_input_event(zoom_out_camera_event)
#
#func simulate_zoom_in_input():
	#var zoom_in_camera_event = InputEventAction.new()
	#zoom_in_camera_event.action = "scroll_up"
	#zoom_in_camera_event.pressed = true
	#Input.parse_input_event(zoom_in_camera_event)

#func simulate_camera_reset_input():
	#var reset_camera_event = InputEventAction.new()
	#reset_camera_event.action = "middle_mouse"
	#reset_camera_event.pressed = true
	#Input.parse_input_event(reset_camera_event)
