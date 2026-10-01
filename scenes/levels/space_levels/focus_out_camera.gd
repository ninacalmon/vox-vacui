class_name FocusOutCamera
extends Node2D


@export var camera: Camera2D

@export var max_zoom_out: float = 0.35

@export var focus_growth_speed: float = 0.4
@export var focus_decay_speed: float = 4

@export var zoom_smoothness: float = 3.0

var default_zoom: Vector2
var zoom_amount: float = 1.0


func _ready() -> void:
	default_zoom = camera.default_zoom


func _process(delta: float) -> void:
	if Globals.is_cutscene:
		return

	var holding: bool = Input.is_action_pressed("focus_out")

	if holding:
		zoom_amount -= delta * focus_growth_speed
	else:
		zoom_amount += delta * focus_decay_speed

	zoom_amount = clamp(zoom_amount, max_zoom_out, 1.0)

	var target_zoom: Vector2 = default_zoom * zoom_amount

	camera.zoom = camera.zoom.lerp(target_zoom, zoom_smoothness * delta)
