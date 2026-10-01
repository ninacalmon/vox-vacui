extends Area2D

var player_burning: bool = false

var player: Player

@onready var sun_burn: AudioStreamPlayer = $SunBurn

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if not player_burning or player == null:
		return
	apply_damage()

func apply_damage():
	player.take_damage(10, self)

func _on_body_entered(body: PhysicsBody2D):
	if body is Player:
		player = body
		sun_burn.play()
		player_burning = true
		#EventBus.player_death.emit(false)
	else: body.call_deferred("queue_free")
