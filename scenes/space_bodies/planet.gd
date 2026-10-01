class_name Planet
extends BodySetup

@export var _rotate: bool = true

@export var rotation_speed: float = 0.05

func _ready() -> void:
	##setup
	if gravitational_field:
		gravitational_field.initialize()
	if body_randomizer:
		body_randomizer.initialize(sprite, collision)

func _process(delta: float) -> void:
	linear_velocity = Vector2.ZERO

	if _rotate:
		rotation += rotation_speed * delta
