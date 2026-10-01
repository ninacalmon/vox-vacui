extends Sprite2D

@onready var shake_module: ShakeModule = $ShakeModule

func _ready() -> void:
	SpaceshipEventBus.resource_count_started.connect(_on_resource_count_started)

func _on_resource_count_started(duration: float):
	shake_module.shake(self, duration, 0.3)
