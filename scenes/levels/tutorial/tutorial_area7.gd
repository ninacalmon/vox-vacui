extends Area2D

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D

@onready var audio_stream_player: AudioStreamPlayer = $CritterSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player and rigid_body_2d:
		rigid_body_2d.queue_free()
		audio_stream_player.play()
