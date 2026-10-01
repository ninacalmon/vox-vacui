extends Node2D

@onready var falling_animation: AnimationPlayer = $FallingAnimation

func _ready() -> void:
	SpaceshipEventBus.resource_count_started.connect(start_animation)
	hide()

func start_animation(duration):
	show()
	if duration < 6:
		falling_animation.play("Medium")
	else:
		falling_animation.play("Maximum")

	await falling_animation.animation_finished

	hide()
