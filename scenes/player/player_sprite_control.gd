class_name PlayerSprite2D
extends Sprite2D

@export var seconds_per_frame: float = 0.3

var is_propelling: bool = false

var current_direction: String = ""

@onready var backpack_sprite_2d: Sprite2D = $BackpackSprite2D

func update_sprite(facing_direction: String):
	if facing_direction != current_direction:
		current_direction = facing_direction
		restart_animation()

	match facing_direction:
		"up", "down":
			frame_coords.y = 0
		"left":
			frame_coords.y = 3
		"right":
			frame_coords.y = 1

	backpack_sprite_2d.frame_coords.y = frame_coords.y

func restart_animation():
	is_propelling = false
	await get_tree().process_frame
	is_propelling = true
	animate_propelling()

func start_animation():
	if is_propelling:
		return

	is_propelling = true
	animate_propelling()

func stop_animation():
	is_propelling = false

func animate_propelling():
	while is_propelling and is_inside_tree():
		frame_coords.x = 1
		await get_tree().create_timer(seconds_per_frame).timeout
		if not is_propelling:
			break

		frame_coords.x = 2
		await get_tree().create_timer(seconds_per_frame).timeout
		if not is_propelling:
			break

		frame_coords.x = 3

		while is_propelling:
			await get_tree().create_timer(0.0).timeout

	while frame_coords.x > 0:
		frame_coords.x -= 1
		await get_tree().create_timer(seconds_per_frame).timeout
