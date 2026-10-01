class_name GravitationalField
extends Area2D
@export_range(0, 10000000000, 0.0001) var mass_to_radius_multiply: float = 3.0
@export_range(0.3, 1.3, 0.01, "lower number = higher increase. and vice-versa") var increase_with_proximity: float = 1 ##lower number, higher increase.

signal grav_field_entered(body: PhysicsBody2D)

signal grav_field_exited(body: PhysicsBody2D)

@export var owner_body: RigidBody2D

@export var owner_collision_shape: CollisionShape2D

@export var attraction_received_multiply: float = 1.0

@export var attraction_executed_multiply: float = 1.0

var body_near: Array[PhysicsBody2D] = []

var activated: bool = false

var collision_exception_array: Array[PhysicsBody2D]

@onready var _range: CollisionShape2D = $Range

func _physics_process(_delta: float) -> void:
	if not activated:
		return
	for b in body_near:
		apply_gravity(b)

func initialize() -> void:
	var range_circle: CircleShape2D = _range.shape.duplicate()
	range_circle.radius = owner_body.mass * mass_to_radius_multiply
	_range.shape = range_circle

	area_entered.connect(_on_grav_field_entered_by_area)
	area_exited.connect(_on_grav_field_exited_by_area)

	activated = true

func apply_gravity(near_body: PhysicsBody2D):
	if near_body == owner_body:
		return
	if not is_instance_valid(near_body):
		return

	var direction = owner_body.global_position - near_body.global_position
	var distance = max(direction.length(), 10.0)
	var dir_normalized = direction.normalized()
	var G = 1000.0
	var base_force = (G * (owner_body.mass * near_body.mass)
		/ pow(distance, 2 * increase_with_proximity))

	# force applied to the OTHER body (how much we attract it)
	var force_on_other = dir_normalized * base_force * attraction_executed_multiply
	# force applied to THIS body (how much we get attracted)
	var force_on_self = -dir_normalized * base_force * attraction_received_multiply

	near_body.apply_central_force(force_on_other)
	owner_body.apply_central_force(force_on_self)

func _add_collision_exception_with(body: PhysicsBody2D):
	collision_exception_array.append(body)

func _on_grav_field_entered_by_area(area: Area2D):
	if not (area is GravitationalField):
		return
	var body = area.owner_body
	grav_field_entered.emit(body)
	body_near.append(body)

func _on_grav_field_exited_by_area(area: Area2D):
	if not (area is GravitationalField):
		return
	var body = area.owner_body
	grav_field_exited.emit(body)
	body_near.erase(body)
