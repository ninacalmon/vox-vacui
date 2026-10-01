class_name EnemyVermin
extends Enemy

enum State {
	IDLE,
	CHASE,
	FLEE,
}

@export var stun_time: float = 6

@export var flee_speed_multiplier: float = 1.0

@export var safe_distance: float = 180

@export var fleeing_time: Vector2 = Vector2(1, 1.5)

var state: State = State.IDLE

var can_attack: bool = true

var chase_timer: float = 0.0

@onready var mat: ShaderMaterial = sprite_2d.material

func _ready():
	hurt_box.damage_taken.connect(_on_damage_taken)
	aggro_area.body_entered.connect(_on_aggro_entered)

func _process(delta):
	if not is_instance_valid(player):
		return

	# Timer that controls when we can go back to chasing
	if state == State.FLEE and chase_timer > 0:
		chase_timer -= delta

	# Transition: FLEE -> CHASE
	if state == State.FLEE:
		var dist = global_position.distance_to(player.global_position)

		## If enemy still isnt on a safe distance from player when
		## flee timer reaches zero, reset timer and keep fleeing
		if dist <= safe_distance:
			start_flee_timer()

		if dist >= safe_distance and chase_timer <= 0:
			state = State.CHASE
			can_attack = true

func _integrate_forces(_state: PhysicsDirectBodyState2D):
	match state:
		State.IDLE:
			pass

		State.CHASE:
			var dir_to_player = global_position.direction_to(player.global_position)
			apply_movement(_state, dir_to_player, speed)

			var dist = global_position.distance_to(player.global_position)

			if dist <= attack_distance and can_attack:
				perform_attack()
				state = State.FLEE
				start_flee_timer()

		State.FLEE:
			var dir = player.global_position.direction_to(global_position)
			apply_movement(_state, dir, speed * flee_speed_multiplier)

			# If player gets close again → reset timer (keep fleeing)
			var dist = global_position.distance_to(player.global_position)
			if dist < safe_distance:
				start_flee_timer()

	# Clamp velocity
	if _state.linear_velocity.length() > max_velocity:
		_state.linear_velocity = _state.linear_velocity.normalized() * max_velocity

	# Snake rotation
	if _state.linear_velocity.length() > 5:
		rotation = _state.linear_velocity.angle()

# Core behavior
func perform_attack():
	can_attack = false

	# Apply stun
	if player.has_method("apply_stun"):
		player.apply_stun(stun_time)

	# Optional small damage
	if player.has_method("take_damage"):
		player.take_damage(1, self)

func start_flee_timer():
	chase_timer = randf_range(fleeing_time.x, fleeing_time.y)

# Movement
func apply_movement(state_physics: PhysicsDirectBodyState2D, direction: Vector2, move_speed: float):
	if direction == Vector2.ZERO:
		return

	state_physics.apply_central_force(direction * move_speed)
	steer_enemy_velocity(state_physics, direction)

func steer_enemy_velocity(_state: PhysicsDirectBodyState2D, target_dir: Vector2):
	var vel = _state.linear_velocity
	var magnitude = vel.length()

	if magnitude < 30:
		return

	var target_vel = target_dir * magnitude
	var angle = vel.angle_to(target_vel)

	var max_turn = 0.05
	angle = clamp(angle, -max_turn, max_turn)

	_state.linear_velocity = vel.rotated(angle)

func flash():
	if not mat:
		return
	mat.set_shader_parameter("tint_strength", 1.0)
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("tint_strength", 0)

# Signals
func _on_aggro_entered(body):
	if body is Player and state == State.IDLE:
		state = State.FLEE
		player = body
		start_flee_timer()
		sleeping = false

func _on_damage_taken(amount: float, _causer: Node2D):
	life -= amount
	flash()

	if life <= 0:
		queue_free()
