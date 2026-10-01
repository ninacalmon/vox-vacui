class_name BulletShooter
extends Node2D

@export var base_cooldown: float = 0.2

var cooldown: float = 0

var aim_direction: Vector2 = Vector2.RIGHT

var inverse_control_on: bool = false

@onready var bullet_sfx: AudioStreamPlayer = $BulletSFX

@onready var arrow_pivot: Node2D = $ArrowPivot

@onready var sprite_2d: Sprite2D = $ArrowPivot/Sprite2D

@onready var bullet_scene: PackedScene = load(StatsManager.player_current_bullet)

func _process(delta: float) -> void:
	if Globals.is_cutscene:
		return

	cooldown -= delta
	if cooldown < 0:
		cooldown = 0

	handle_aim()
	handle_aim_mouse()
	handle_shoot()

func handle_aim():
	if not Input.get_connected_joypads():
		return

	var input_dir: Vector2 = Vector2(
		Input.get_action_strength("r_stk_right") - Input.get_action_strength("r_stk_left"),
		Input.get_action_strength("r_stk_down") - Input.get_action_strength("r_stk_up")
	)

	if input_dir.length() > 0.2:
		aim_direction = input_dir.normalized()

		arrow_pivot.rotation = aim_direction.angle()

func handle_aim_mouse():
	if Input.get_connected_joypads():
		return

	var cursor_dir: Vector2 = global_position.direction_to(get_global_mouse_position())

	if cursor_dir.length() > 0.2:
		aim_direction = cursor_dir.normalized()

		arrow_pivot.rotation = aim_direction.angle()

func handle_shoot():
	if Input.is_action_pressed("shoulderR") or Input.is_action_pressed("left_click"):
		shoot(aim_direction if not inverse_control_on else aim_direction * -1)

func get_input_mouse() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())

func shoot(direction: Vector2):
	if cooldown > 0:
		return

	cooldown = base_cooldown

	var new_bullet: Bullet = bullet_scene.instantiate()
	add_sibling(new_bullet)

	new_bullet.show_behind_parent = true

	new_bullet.global_position = sprite_2d.global_position
	new_bullet.direction = direction
	new_bullet.rotation = direction.angle()

	SFXManager.play_sound(bullet_sfx)

func set_inverse_control(should_inverse: bool):
	inverse_control_on = should_inverse
