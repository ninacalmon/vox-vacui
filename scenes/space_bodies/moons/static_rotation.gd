extends StaticBody2D

@export var _rotate: bool = true

@export var rotation_speed: float = 0.05

func _process(delta: float) -> void:
	if _rotate:
		rotation += rotation_speed * delta
