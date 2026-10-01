extends Control

@export var arrow: Node2D

@export var mothership: RigidBody2D

@export var player: Player

func _process(_delta: float) -> void:
	if not arrow or not player or not mothership:
		return

	visible = not Globals.is_cutscene
	var direction = mothership.global_position - player.global_position
	arrow.rotation = direction.angle()
