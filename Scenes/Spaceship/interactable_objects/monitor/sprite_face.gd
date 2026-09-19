extends AnimatedSprite2D

var _is_visible: bool

@onready var blink_timer: Timer = $BlinkTimer

func _ready() -> void:
	blink_timer.timeout.connect(_on_blink)

func _process(_delta: float) -> void:
	if self.modulate.a > 0.00:
		_is_visible = true
	else: _is_visible = false

func _on_blink():
	if is_visible:
		play("default")
		await animation_finished
	blink_timer.start()
