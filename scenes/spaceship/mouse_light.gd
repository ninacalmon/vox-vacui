extends PointLight2D

var deactivated: bool = false

func _ready() -> void:
	SpaceshipEventBus.resource_count_finished.connect(_on_resource_count_finished)

func _process(_delta: float) -> void:
	if deactivated:
		return

	global_position = get_global_mouse_position()

func _on_resource_count_finished():
	deactivated = true
	enabled = false
