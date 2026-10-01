class_name EnemyLarvae
extends Enemy

enum State {
	CHASE,
	INFLATING,
	DEFLATING,
	EXPLOSION_COMMITTED,
	EXPLOSION_DEATH,
	EXPLODE,
}

@export var stun_time: float = 6

@export var death_time_to_explode: float = 1.5

@export var deflate_speed_multiplier: float = 1.5

@export var no_return_ratio: float = 0.75 # % of time where it commits

# Movement
@export var puff_speed_multiplier: float = 0.2

# Puff timing (MAIN CONTROL)
@export var time_to_explode: float = 3.5

# Explosion
@export var explosion_area: Area2D

var state: State = State.CHASE

var puff_timer: float = 0.0

var player_inside_aggro: bool = false

@onready var mat: ShaderMaterial = sprite_2d.material

@onready var explosion_particles: GPUParticles2D = $ExplosionParticles

@onready var explosion_aurea_sprite: Sprite2D = $ExplosionAureaSprite

func _ready():
	hurt_box.damage_taken.connect(_on_damage_taken)
	aggro_area.body_entered.connect(_on_aggro_entered)
	aggro_area.body_exited.connect(_on_aggro_exited)
	player = get_tree().get_first_node_in_group("Player_Group")

	explosion_aurea_sprite.modulate.a = 0

func _process(delta):
	if not is_instance_valid(player):
		return

	match state:
		State.CHASE:
			pass

		State.INFLATING:
			handle_puff(delta)

		State.DEFLATING:
			handle_deflate(delta)

		State.EXPLOSION_DEATH:
			handle_explosion_death(delta)

		State.EXPLOSION_COMMITTED:
			handle_puff(delta)

		State.EXPLODE:
			explode()

func _integrate_forces(state_physics: PhysicsDirectBodyState2D):
	if not is_instance_valid(player):
		return

	match state:
		State.CHASE:
			var dir = global_position.direction_to(player.global_position)
			apply_movement(state_physics, dir, speed)

		State.INFLATING:
			var dir = global_position.direction_to(player.global_position)
			apply_movement(state_physics, dir, speed * puff_speed_multiplier)

		State.DEFLATING:
			state_physics.linear_velocity = Vector2.ZERO

		State.EXPLOSION_COMMITTED:
			var dir = global_position.direction_to(player.global_position)
			apply_movement(state_physics, dir, speed * puff_speed_multiplier)

		State.EXPLOSION_DEATH:
			state_physics.linear_velocity = Vector2.ZERO

		State.EXPLODE:
			state_physics.linear_velocity = Vector2.ZERO

	# Velocity clamp
	var vel = state_physics.linear_velocity
	var current_speed = vel.length()

	if current_speed > max_velocity:
		state_physics.linear_velocity = vel.normalized() * max_velocity

	# Rotation
	if state_physics.linear_velocity.length() > 5:
		rotation = state_physics.linear_velocity.angle()

# Puff logic (TIME-BASED)
func handle_puff(delta):
	puff_timer += delta
	puff_timer = clamp(puff_timer, 0.0, time_to_explode)

	if puff_timer > time_to_explode * no_return_ratio:
		state = State.EXPLOSION_COMMITTED

	if puff_timer >= time_to_explode:
		state = State.EXPLODE

	update_shader()

func handle_deflate(delta):
	if puff_timer > 0:
		puff_timer -= delta * deflate_speed_multiplier
		puff_timer = max(puff_timer, 0.0)
	else:
		state = State.CHASE

	update_shader()

# Shader
func update_shader(puff_to_explosion_time: float = time_to_explode):
	var normalizes_aurea: float = (puff_timer / puff_to_explosion_time)
	explosion_aurea_sprite.modulate.a = normalizes_aurea

	if mat:
		var normalized: float = (puff_timer / puff_to_explosion_time) * 0.6

		mat.set_shader_parameter("inflate", normalized)

# Explosion (AoE)
func handle_explosion_death(delta):
	puff_timer += delta
	puff_timer = clamp(puff_timer, 0.0, time_to_explode)

	if puff_timer >= death_time_to_explode:
		state = State.EXPLODE

	update_shader(death_time_to_explode)

func explode():
	var colliders = explosion_area.get_overlapping_bodies()
	colliders.append_array(explosion_area.get_overlapping_areas())

	for collider in colliders:
		if collider == self:
			continue

		if collider.has_method("take_damage"):
			collider.take_damage(damage, self)

		if collider.has_method("apply_stun"):
			collider.apply_stun(stun_time)

	var p = explosion_particles
	p.one_shot = true
	p.reparent(get_tree().current_scene)
	p.global_position = global_position

	p.emitting = true

	queue_free()

# Movement
func apply_movement(state_physics: PhysicsDirectBodyState2D, direction: Vector2, move_speed: float):
	if direction == Vector2.ZERO:
		return

	if state_physics.linear_velocity.length() < max_velocity:
		state_physics.apply_central_force(direction * move_speed)

	steer_enemy_velocity(state_physics, direction)

func steer_enemy_velocity(state_physics: PhysicsDirectBodyState2D, target_dir: Vector2):
	var vel = state_physics.linear_velocity
	var magnitude = vel.length()

	if magnitude < 30:
		return

	var target_vel = target_dir * magnitude
	var angle = vel.angle_to(target_vel)

	var max_turn = 0.05
	angle = clamp(angle, -max_turn, max_turn)

	state_physics.linear_velocity = vel.rotated(angle)

func flash():
	if not mat:
		return

	mat.set_shader_parameter("tint_strength", 1.0)
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("tint_strength", 0)

# Signals
func _on_aggro_entered(body):
	if body is Player:
		player = body
		player_inside_aggro = true
		state = State.INFLATING

func _on_aggro_exited(body):
	if body is Player:
		player_inside_aggro = false

		if state != State.EXPLOSION_COMMITTED:
			state = State.DEFLATING

func _on_damage_taken(amount: float, _causer: Node2D):
	life -= amount
	flash()

	if life <= 0:
		state = State.EXPLOSION_DEATH
