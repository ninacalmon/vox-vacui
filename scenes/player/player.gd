class_name Player
extends BodySetup

@export var camera: Camera2D

@export var hurt_box_player: HurtBoxPlayer

@export var bullet_shooter_module: BulletShooter

@export var base_destroy_tolerance_timer: float = 0.5

@export var start_of_game: bool = true

var speed: float = StatsManager.player_speed

var impulse_speed: float = StatsManager.player_impulse_speed

var break_speed: float = StatsManager.player_break_speed

var max_velocity: float = StatsManager.player_max_velocity

var impulse_cooldown_timer: float = StatsManager.player_impulse_cooldown_duration

var destroy_tolerance_timer: float

var player_init_pos: Vector2

var original_speed: float = speed

var can_destroy: bool

var emitted_fuel_waning: bool = false

var facing_direction: String

var is_stuned: bool

var init_camera_zoom: Vector2

var last_facing_direction: String = "down"

@onready var propulsor_sfx: AudioStreamPlayer = $SFX/PropulsorSFX

@onready var teleport_sfx: AudioStreamPlayer = $SFX/TeleportSFX

@onready var sprite_2d: PlayerSprite2D = $Sprite2D

@onready var dash_sfx: AudioStreamPlayer = $SFX/DashSFX

@onready var dash_fail_sfx: AudioStreamPlayer = $SFX/DashFailSFX

@onready var sprite_stun: Sprite2D = $SpriteStun

func _ready() -> void:
	if body_randomizer:
		body_randomizer.initialize(sprite, collision)
	if gravitational_field:
		gravitational_field.initialize()
	if gravitational_field_resources:
		gravitational_field_resources.initialize()

	StatsManager.player_current_fuel = StatsManager.player_max_fuel
	StatsManager.player_current_health = StatsManager.player_max_health

	player_init_pos = global_position + Vector2(0.0, -50)
	EventBus.player_almost_out_of_bounds.connect(_on_player_almost_out_of_bounds)
	EventBus.player_out_of_bounds.connect(_on_player_out_of_bounds)
	EventBus.cutscene_off.connect(start_game)

	init_camera_zoom = camera.zoom

func _process(delta: float) -> void:
	impulse_cooldown_timer -= delta
	destroy_tolerance_timer -= delta
	if impulse_cooldown_timer <= 0:
		impulse_cooldown_timer = 0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Globals.is_cutscene:
		linear_velocity = Vector2.ZERO
		return

	## Movement here vvv
	movement(state)
	steer_velocity(state)
	impulse_burst(state)
	break_stop(state)

	update_facing_direction(state.linear_velocity)
	sprite_2d.update_sprite(facing_direction)

	StatsManager.player_current_linear_velocity = state.linear_velocity

	if state.linear_velocity.length() > max_velocity:
		state.linear_velocity = state.linear_velocity.normalized() * max_velocity


	if Input.is_action_just_pressed("teleport") and Globals.can_teleport:
		execute_teletransport()

func start_game():
	if start_of_game:
		self.apply_force(Vector2(0.0, -speed * 30))
		propulsor_sfx.volume_db = -22
		SFXManager.play_sound(propulsor_sfx)
		propulsor_sfx.volume_db = -45
		start_of_game = false

func execute_teletransport():
	if StatsManager.player_has_cadaver:
		return

	SFXManager.play_sound(teleport_sfx)

	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "zoom", camera.zoom * 1.6, 0.2)
	tween.tween_property(self, "modulate", Color(18.892, 18.892, 18.892), 0.1)
	tween.set_parallel(false)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	await tween.finished
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "zoom", init_camera_zoom, 0.2)
	linear_velocity = Vector2.ZERO
	global_position = player_init_pos

func movement(state):
	var input_dir: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	if input_dir == Vector2.ZERO:
		sprite_2d.stop_animation()
		return

	#sprite_2d.animate_start_propelling()
	sprite_2d.start_animation()

	if is_stuned:
		input_dir *= -1
	state.apply_central_force(input_dir * speed)
	update_fuel()
	SFXManager.play_sound(propulsor_sfx)

func update_facing_direction(dir: Vector2):
	if dir == Vector2.ZERO:
		return

	var bias: float = 0.05

	if abs(dir.x) > abs(dir.y) + bias:
		facing_direction = "right" if dir.x > 0 else "left"
	elif abs(dir.y) > abs(dir.x) + bias:
		facing_direction = "down" if dir.y > 0 else "up"
	else:
		facing_direction = last_facing_direction

	last_facing_direction = facing_direction

func impulse_burst(state):
	if Input.is_action_just_pressed("impulse_burst"):
		if impulse_cooldown_timer <= 0:
			SFXManager.play_sound(dash_sfx)
			impulse_cooldown_timer = StatsManager.player_impulse_cooldown_duration
			update_fuel(true)
			state.apply_impulse(linear_velocity.normalized() * impulse_speed)
		else: SFXManager.play_sound(dash_fail_sfx)

func break_stop(state):
	if Input.is_action_pressed("break_stop"):
		state.linear_velocity = state.linear_velocity.move_toward(Vector2.ZERO, break_speed)

func steer_velocity(state: PhysicsDirectBodyState2D):
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	if input_dir == Vector2.ZERO:
		return

	var vel = state.linear_velocity
	var magnitude = vel.length()

	if magnitude < 50:
		return

	var target_vel = input_dir * magnitude
	var angle = vel.angle_to(target_vel)

	var max_turn = StatsManager.player_max_turn
	angle = clamp(angle, -max_turn, max_turn)

	state.linear_velocity = vel.rotated(angle)

func update_fuel(is_impulse: bool = false):
	if is_impulse:
		StatsManager.player_current_fuel -= StatsManager.FUEL_IMPULSE_USE_STEP
	else:
		StatsManager.player_current_fuel -= StatsManager.FUEL_USE_STEP
	EventBus.fuel_used.emit()

	if StatsManager.player_current_fuel <= StatsManager.player_max_fuel/5 and not emitted_fuel_waning:
		emitted_fuel_waning = true
		EventBus.almost_out_of_fuel.emit()
	if StatsManager.player_current_fuel <= 0:
		EventBus.player_death.emit(true)

func apply_stun(stun_duration: float):
	is_stuned = true
	bullet_shooter_module.set_inverse_control(is_stuned)

	linear_velocity *= 0.1
	speed /= 2
	PopUpSystem.show_text("Você se sente atordoado", stun_duration)
	sprite_stun.show()
	var tween = create_tween()
	tween.tween_property(sprite_stun, "modulate:a", 1, 0.3)
	await get_tree().create_timer(stun_duration).timeout

	is_stuned = false
	bullet_shooter_module.set_inverse_control(is_stuned)

	speed = original_speed
	tween.tween_property(sprite_stun, "modulate:a", 0, 0.3)
	sprite_stun.hide()

func take_damage(amount: float, causer: Node2D):
	hurt_box_player._on_enemy_damage_taken(amount, causer)

func _on_player_almost_out_of_bounds():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "linear_velocity", linear_velocity / 3, 1)

func _on_player_out_of_bounds():
	execute_teletransport()
