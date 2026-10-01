extends Node

const cursor_speed: float = 500.0

const deadzone: float = 0.2

@onready var mouse_pos: Vector2 = get_viewport().get_mouse_position()

func _process(delta: float) -> void:
	if not Input.get_connected_joypads():
		Globals.fake_mouse_input = false
		return

	var move = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	if move.length() < deadzone:
		move = Vector2.ZERO
	else:
		move = move.normalized()

	mouse_pos += move * cursor_speed * delta
	Input.warp_mouse(mouse_pos)

	if Input.is_action_just_pressed("confirm"):
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		click.position = mouse_pos
		get_viewport().push_input(click)

	if Input.is_action_just_released("confirm"):
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = false
		click.position = mouse_pos
		get_viewport().push_input(click)

	Globals.fake_mouse_input = true
