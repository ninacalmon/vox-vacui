class_name PanViewModule
extends CanvasLayer

@export var camera: SpaceshipCam

@export var total_rooms_range: Vector2i = Vector2i(-1, 1)

@export var room_width: int

#@export var viewport_border_width: float = 530
@export var camera_speed: float = 0.8

var can_look_left: bool = true

var can_look_right: bool = true

var current_room: int = 0

var deactivated: bool = true

var room_0_position_x: float

var room_1_position_x: float

var room_minus_1_position_x: float

@onready var button_l: Button = $ButtonL

@onready var button_r: Button = $ButtonR

func initialize() -> void:
	deactivated = false
	button_l.pressed.connect(_on_left_button_pressed)
	button_r.pressed.connect(_on_right_button_pressed)

	room_0_position_x = camera.global_position.x
	room_1_position_x = room_0_position_x + room_width
	room_minus_1_position_x = room_0_position_x - room_width

func look_side(side: String):
	var new_pos = camera.global_position
	camera.is_busy = true


	match side:
		"left":
			can_look_left = false
			new_pos -= Vector2(room_width, 0)
			current_room -= 1
		"right":
			can_look_right = false
			new_pos += Vector2(room_width, 0)
			current_room += 1

	var tween = create_tween()
	tween.tween_property(camera, "global_position", new_pos, camera_speed)

	await tween.finished

	camera.is_busy = false

func update_current_room():
	var is_camera_on_room_zero: bool = abs(camera.global_position.x - \
		room_0_position_x) < 50

	var is_camera_on_room_1: bool = abs(camera.global_position.x - \
		room_1_position_x) < 50

	var is_camera_on_room_minus_1: bool = abs(camera.global_position.x - \
		room_minus_1_position_x) < 50

	if is_camera_on_room_zero:
		current_room = 0
	elif is_camera_on_room_1:
		current_room = 1
	elif is_camera_on_room_minus_1:
		current_room = -1

func _on_left_button_pressed():
	if camera.is_busy or \
	camera.is_focused or \
	current_room <= total_rooms_range.x or \
	deactivated:
		return
	look_side("left")

func _on_right_button_pressed():
	if camera.is_busy or \
	camera.is_focused or \
	current_room >= total_rooms_range.y or \
	deactivated:
		return
	look_side("right")
