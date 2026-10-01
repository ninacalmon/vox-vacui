class_name DamageModule
extends Node2D

signal damage_taken(amount: float, causer: RigidBody2D)

@export var owner_body: RigidBody2D

@export var minimum_impact: float = 50

@onready var collision_sfx: AudioStreamPlayer = $CollisionSFX

func _ready() -> void:
	owner_body.body_entered.connect(_on_body_collided)
	if owner_body is Asteroid:
		match owner_body.asteroid_size:
			"small": collision_sfx.pitch_scale = 2.0
			"medium": collision_sfx.pitch_scale = 1.0
			"big": collision_sfx.pitch_scale = 0.6

func _on_body_collided(body: PhysicsBody2D):
	if body is BlackHole \
	or body is SuperMBlackHole \
	or body is CollectableResource \
	or body is StaticBody2D:
		return

	else:
		if body is Player:
			SFXManager.play_sound(collision_sfx)
		var relative_velocity = owner_body.linear_velocity - body.linear_velocity
		var impact_hardness = relative_velocity.length()

		if impact_hardness <= minimum_impact:
			if body is Player:
				ControllerVibration.vibrate_controller()

			return

		damage_taken.emit(impact_hardness, body)
