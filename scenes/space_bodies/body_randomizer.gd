class_name BodyRandomizer
extends Node2D

@export var owner_body: RigidBody2D

@export_group("Activate")
@export var rand_scale: bool = true

@export var rand_rotation: bool = true

@export var rand_linear_velocity: bool = true

@export var rand_angular_velocity: bool = true

@export_group("Spawn Randomization")
@export_subgroup("Scale")
@export var scale_min: float = 1.0

@export var scale_max: float = 5.0

@export_subgroup("Rotation")
@export var rotation_min: float = -360.0

@export var rotation_max: float = 360.0

@export_subgroup("Linear Velocity")
@export var lin_vel_min: float = -10.0

@export var lin_vel_max: float = 10.0

@export_subgroup("Angular Velocity")
@export var ang_vel_min: float = -1.0

@export var ang_vel_max: float = 1.0

func initialize(sprite, collision) -> void:
	if rand_scale:
		randomize_scale(sprite, collision)
	if rand_rotation:
		randomize_rotation()
	if rand_linear_velocity:
		randomize_linear_velocity()
	if rand_angular_velocity:
		randomize_angular_velocity()

func randomize_scale(sprite: Node2D, collision: CollisionShape2D):
	var rand_scale_chosen = randf_range(scale_min, scale_max)
	sprite.scale *= rand_scale_chosen
	collision.scale *= rand_scale_chosen

func randomize_rotation():
	owner_body.rotation = deg_to_rad(randf_range(rotation_min, rotation_max))

func randomize_linear_velocity():
	owner_body.linear_velocity = Vector2(randf_range(lin_vel_min, lin_vel_max),\
	randf_range(lin_vel_min, lin_vel_max))

func randomize_angular_velocity():
	owner_body.angular_velocity = randf_range(ang_vel_min, ang_vel_max)
