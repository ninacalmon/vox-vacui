extends Camera2D

@onready var phantom_camera_noise_emitter_2d: PhantomCameraNoiseEmitter2D = $"../PhantomCameraNoiseEmitter2D"

func _ready() -> void:
	phantom_camera_noise_emitter_2d.emit()
