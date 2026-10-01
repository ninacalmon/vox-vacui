class_name SuperMBlackHole
extends BodySetup

var player: Player

var check_distance: bool = false

@onready var gulp_sfx: AudioStreamPlayer = $GulpSFX

func _ready() -> void:
	if body_randomizer:
		body_randomizer.initialize(sprite, collision)
	if gravitational_field:
		gravitational_field.initialize()
	if gravitational_field_resources:
		gravitational_field_resources.initialize()

	self.body_entered.connect(_on_body_entered)
	gravitational_field.body_entered.connect(_on_gravitational_field_body_entered)
	gravitational_field.body_exited.connect(_on_gravitational_field_body_exited)

func _process(_delta: float) -> void:
	if not check_distance:
		return
	if player and player.global_position.distance_to(global_position) < 70:
		SFXManager.play_sound(gulp_sfx)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = Vector2.ZERO
	state.angular_velocity = 0.0

func start_suck_animation(body, center, r, a, duration): # lá ele - AI vvvvvvv
	if not is_instance_valid(body):
		return

	var tween = create_tween()
	tween.bind_node(body)

	# 1. Define the function
	var my_lambda = func(t, b, c, rad, ang):
		if not is_instance_valid(b):
			return

		var current_radius = lerp(rad, 0.0, t)
		var current_angle = ang + (t * TAU * 3.0)

		var offset = Vector2(cos(current_angle), sin(current_angle)) * current_radius
		b.global_position = c + offset
		b.scale = Vector2.ONE * lerp(1.0, 0.1, t)

	# 2. Bind the extra arguments to the lambda FIRST
	var bound_lambda = my_lambda.bind(body, center, r, a)

	# 3. Pass the already-bound lambda into the tween
	tween.tween_method(bound_lambda, 0.0, 1.0, duration)

	await tween.finished

func _on_gravitational_field_body_entered(_body: RigidBody2D):
	if _body is Player:
		player = _body
		check_distance = true

func _on_gravitational_field_body_exited(_body: RigidBody2D):
	if _body is Player:
		check_distance = false

func _on_body_entered(body: Node2D) -> void:
	var center = global_position
	var to_body = body.global_position - center
	var radius = to_body.length()
	var angle = to_body.angle()
	var duration = 1.5

	await start_suck_animation(body, center, radius, angle, duration)

	if body is Player:
		EventBus.player_death.emit(false)
	else:
		body.queue_free()
