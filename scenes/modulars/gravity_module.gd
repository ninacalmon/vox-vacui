class_name GravityModule
extends Node

@export var target: RigidBody2D

@export var gravity_strength: float = 980.0

@export var gravity_direction: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target) or gravity_direction == Vector2.ZERO:
		return

	target.apply_central_force(gravity_direction.normalized() * gravity_strength)

func set_gravity(direction: Vector2):
	gravity_direction = direction.normalized()
