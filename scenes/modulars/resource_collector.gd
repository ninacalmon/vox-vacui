class_name ResourceCollector
extends Area2D

@export var owner_body: RigidBody2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: PhysicsBody2D):
	if not (body is CollectableResource):
		return
	body.add_collision_exception_with(owner_body)
	body.target = owner_body
	body.following = true
