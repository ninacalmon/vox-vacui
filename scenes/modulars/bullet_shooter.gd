class_name BulletShooter
extends Node2D

@export var base_cooldown: float = 0.2

@export var lead_strength: float = 1.0

var cooldown: float = 0

var aim_direction: Vector2 = Vector2.RIGHT

var inverse_control_on: bool = false

@onready var bullet_sfx: AudioStreamPlayer = $BulletSFX

@onready var arrow_pivot: Node2D = $ArrowPivot

@onready var sprite_2d: Sprite2D = $ArrowPivot/Sprite2D

@onready var bullet_scene: PackedScene = load(StatsManager.player_current_bullet)

@export var player_targeting: PlayerTargeting

func _process(delta: float) -> void:
	if Globals.is_cutscene:
		return

	cooldown -= delta
	if cooldown < 0:
		cooldown = 0

	handle_aim()
	handle_aim_mouse()
	handle_aim_lock()
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

func handle_aim_lock():
	if not is_instance_valid(player_targeting):
		return

	if is_instance_valid(player_targeting.current_target):
		aim_direction = global_position.direction_to(player_targeting.current_target.global_position)
		arrow_pivot.rotation = aim_direction.angle()

func handle_shoot():
	if Input.is_action_pressed("shoulderR") or Input.is_action_pressed("left_click"):
		shoot(aim_direction if not inverse_control_on else aim_direction * -1)

func get_input_mouse() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())

func get_lead_direction(target: Enemy, bullet_speed: float) -> Vector2:
	var muzzle_position: Vector2 = sprite_2d.global_position

	# No valid bullet speed: aim straight at the target
	if bullet_speed <= 0:
		return muzzle_position.direction_to(target.global_position)

	# Target velocity compared to the player (bullet rides with the player)
	var player_velocity: Vector2 = StatsManager.player_current_linear_velocity
	var relative_velocity: Vector2 = target.linear_velocity - player_velocity

	# Time the bullet takes to reach the target where it is right now
	var distance: float = muzzle_position.distance_to(target.global_position)
	var flight_time: float = distance / bullet_speed

	# Where the target will be when the bullet arrives
	var lead_offset: Vector2 = relative_velocity * flight_time * lead_strength
	var aim_point: Vector2 = target.global_position + lead_offset

	return muzzle_position.direction_to(aim_point)

func shoot(direction: Vector2):
	if cooldown > 0:
		return

	cooldown = base_cooldown

	var new_bullet: Bullet = bullet_scene.instantiate()
	add_sibling(new_bullet)

	new_bullet.show_behind_parent = true

	new_bullet.global_position = sprite_2d.global_position

	var locked_target: Enemy = null
	if is_instance_valid(player_targeting):
		locked_target = player_targeting.current_target

	var final_direction: Vector2 = direction
	if is_instance_valid(locked_target) and not inverse_control_on:
		final_direction = get_lead_direction(locked_target, new_bullet.speed)

	new_bullet.direction = final_direction
	new_bullet.rotation = final_direction.angle()

	SFXManager.play_sound(bullet_sfx)

func set_inverse_control(should_inverse: bool):
	inverse_control_on = should_inverse
