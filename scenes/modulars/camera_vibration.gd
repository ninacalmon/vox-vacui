extends Node2D
## strength_index guide:
## 0: low
## 1: medium
## 2: high
## 3: very high

@export var camera: Camera2D

var threshold = 0.01

var shake_strength

var shake_decay

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	randomize()

	EventBus.vibrate.connect(_on_vibrate)

func _process(delta: float):
	if shake_strength and shake_strength > 0 and shake_decay and shake_decay > 0 and self.camera:
		self.camera.offset = get_random_offset()
		var decay = 1.0 - pow(threshold, delta / shake_decay)
		self.shake_strength = lerpf(self.shake_strength, 0, decay)

func apply_shake(shake_str: float, shake_dcay: float):
	self.shake_strength = shake_str
	self.shake_decay = shake_dcay

func get_random_offset():
	return Vector2(
		rng.randf_range(-self.shake_strength, self.shake_strength),
		rng.randf_range(-self.shake_strength, self.shake_strength)
	)

func _on_vibrate(vibration_index: int):
	match vibration_index:
		0: apply_shake(0.5, 0.2)
		1: apply_shake(3, 0.6)
		2: apply_shake(4, 0.8)
		3: apply_shake(6, 1)
		4: apply_shake(10, 8)
