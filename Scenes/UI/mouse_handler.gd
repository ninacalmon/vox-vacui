class_name MouseHandler
extends Node

var timer: Timer
var mouse_pos: Vector2

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 3.0

	add_child(timer)
	timer.timeout.connect(hide_mouse)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		show_mouse()
		timer.start()


func show_mouse():
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.warp_mouse(mouse_pos)


func hide_mouse():
	mouse_pos = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
