class_name Hook
extends Node2D

@export var stiffness: float = 20.0

@export var damping: float = 4.0

@export var max_distance: float = 200.0

@export var body: RigidBody2D

var player: RigidBody2D

var check_input: bool = false

var connected: bool = false

@onready var line: Line2D = $Line2D

@onready var area_2d: Area2D = $Area2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _physics_process(delta):
	if player == null or not connected:
		return

	var hook_pos = body.global_position
	var player_pos = player.global_position

	var dir = player_pos - hook_pos
	var distance = dir.length()

	if distance == 0:
		return

	var direction = dir.normalized()

	# spring force (Hooke's law)
	var stretch = distance - max_distance
	if stretch > 0:
		var force = direction * (stretch * stiffness)

		# apply force to hook body
		body.apply_force(force)

		# apply opposite force to player
		player.apply_force(-force)

	# damping (reduces jitter)
	body.linear_velocity *= (1.0 - damping * delta)

	# update rope drawing
	line.points = [
		to_local(hook_pos),
		to_local(player_pos)
	]

var emitted: bool = false

func _input(event: InputEvent) -> void:
	if not player:
		return

	if is_player_inside() and not connected:
		if event.is_action_pressed("confirm"):
			connected = true
		StatsManager.player_has_cadaver = true
		PopUpSystem.show_text("Confirme para amarrar sua corda n'A Matriarca.", 3.0)
		EventBus.boss_in_capture_area.emit(true)
	elif not emitted:
		emitted = true
		EventBus.boss_in_capture_area.emit(false)

func is_player_inside() -> bool:
	return area_2d.get_overlapping_bodies().has(player)

func initialize(p: RigidBody2D):
	player = p
