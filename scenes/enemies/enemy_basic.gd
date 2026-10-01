extends Enemy

enum State {
	WANDER,
	CHASE,
	ATTACK,
	RETREAT,
}

var state: State = State.WANDER

var wander_direction: Vector2 = Vector2.ZERO

var wander_timer: float = 0

var retreat_timer: float = 0

@onready var mat: ShaderMaterial = sprite_2d.material

func _ready() -> void:
	hurt_box.damage_taken.connect(_on_damage_taken)

	aggro_area.body_entered.connect(_on_aggro_entered)
	aggro_area.body_exited.connect(_on_aggro_exited)

	randomize_wander()

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	sprite_2d.flip_h = global_position.x > player.global_position.x

	match state:
		State.WANDER:
			wander_timer -= delta
			if wander_timer <= 0:
				randomize_wander()

		State.RETREAT:
			retreat_timer -= delta
			if retreat_timer <= 0:
				retreat_timer = randf_range(0.2, 0.8)
				state = State.CHASE

func _integrate_forces(state_physics: PhysicsDirectBodyState2D) -> void:
	if not is_instance_valid(player):
		return

	match state:
		State.WANDER:
			apply_movement(state_physics, wander_direction, wander_speed)

		State.CHASE:
			var dir = global_position.direction_to(player.global_position)
			var dist = global_position.distance_to(player.global_position)

			if dist <= attack_distance:
				state = State.ATTACK
				return

			apply_movement(state_physics, dir, speed)

		State.ATTACK:
			var dir = global_position.direction_to(player.global_position)
			state_physics.apply_central_impulse(dir * attack_force)
			if randi_range(1, 5) == 1:
				SFXManager.play_sound(attack_sfx)
			state = State.RETREAT
			retreat_timer = retreat_time

		State.RETREAT:
			var dir = player.global_position.direction_to(global_position)
			apply_movement(state_physics, dir, speed * 0.6)

### RTOATTIOJNNN
	if state_physics.linear_velocity.length() > 5:
		rotation = state_physics.linear_velocity.angle()
########

	if state_physics.linear_velocity.length() > max_velocity:
		state_physics.linear_velocity = state_physics.linear_velocity.normalized() * max_velocity

func apply_movement(state_physics: PhysicsDirectBodyState2D, direction: Vector2, move_speed: float):
	if direction == Vector2.ZERO:
		return

	state_physics.apply_central_force(direction * move_speed)
	steer_enemy_velocity(state_physics, direction)

func steer_enemy_velocity(_state: PhysicsDirectBodyState2D, target_dir: Vector2):
	var vel = _state.linear_velocity
	var magnitude = vel.length()

	if magnitude < 50:
		return

	var target_vel = target_dir * magnitude
	var angle = vel.angle_to(target_vel)

	var max_turn = 0.05
	angle = clamp(angle, -max_turn, max_turn)

	_state.linear_velocity = vel.rotated(angle)

func randomize_wander():
	wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_timer = randf_range(1.0, 3.0)

func flash():
	if not mat:
		return
	mat.set_shader_parameter("tint_strength", 1.0)
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("tint_strength", 0)

func _on_aggro_entered(body):
	if body == player:
		state = State.CHASE

func _on_aggro_exited(body):
	if body == player:
		state = State.WANDER

func _on_damage_taken(amount: float, _causer: Node2D):
	life -= amount
	flash()
	if life <= 0:
		queue_free()
