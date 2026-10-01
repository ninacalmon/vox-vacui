class_name FocusModule
extends Node2D

@export var camera: SpaceshipCam

@export var zoom_speed: float = 1.0

var subject: Node2D

@onready var init_zoom: Vector2 = camera.zoom

@onready var init_position: Vector2 = camera.global_position

@onready var center_position: Vector2 = camera.global_position

@onready var pan_view_module: PanViewModule = $"../PanViewModule"

func initialize() -> void:
	SpaceshipEventBus.focus_on.connect(_on_focus_on_requested)
	SpaceshipEventBus.focus_off.connect(_on_focus_off_requested)

func _on_focus_on_requested(
	zoom_in_amount: float, zoom_offset: Vector2, emitter: MainArea, keep_camera: bool
):
	if camera.is_busy or camera.is_focused or not emitter.clickable_highlight.is_mouse_over_area:
		return

	camera.is_busy = true
	camera.is_focused = true

	init_position = camera.position

	var new_zoom = camera.zoom * zoom_in_amount
	## The camera following the mouse uses offset to calculate the position of the camera.
	## Changing offset does not change camera global transform, therefore, we need to
	## "cancel out" the offset here when calculating where to focus
	var new_position = emitter.global_position + zoom_offset - camera.offset

	if not keep_camera:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)

		tween.tween_property(camera, "zoom", new_zoom, zoom_speed)
		tween.parallel().tween_property(camera, "global_position", new_position, zoom_speed)

		await tween.finished

	SpaceshipEventBus.focus_changed.emit(true, emitter)

	subject = emitter

	camera.is_busy = false

func _on_focus_off_requested(reset_to_center_room: bool = false):
	if camera.is_busy or not camera.is_focused:
		return

	camera.is_busy = true
	camera.is_focused = false
	SpaceshipEventBus.focus_changed.emit(false, null)

	camera.offset = Vector2.ZERO

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(camera, "offset", Vector2.ZERO, zoom_speed)
	tween.parallel().tween_property(camera, "zoom", init_zoom, zoom_speed)

	if reset_to_center_room:
		tween.tween_property(camera, "global_position", center_position, zoom_speed)
	else:
		tween.tween_property(camera, "global_position", init_position, zoom_speed)

	await tween.finished

	camera.is_busy = false

	camera.update_current_room()
