class_name BlackHole
extends BodySetup

var is_body_close: bool

var check_distance: bool

var player: Player

@onready var gulp_sfx: AudioStreamPlayer = $GulpSFX

func _ready() -> void:
	if body_randomizer:
		body_randomizer.initialize(sprite, collision)
	if gravitational_field:
		gravitational_field.initialize()
	if gravitational_field_resources:
		gravitational_field_resources.initialize()

	gravitational_field.body_entered.connect(_on_gravitational_field_body_entered)
	gravitational_field.body_exited.connect(_on_gravitational_field_body_exited)

func _process(_delta: float) -> void:
	if not check_distance:
		return
	if player and player.global_position.distance_to(global_position) < 50:
		SFXManager.play_sound(gulp_sfx)

func _on_gravitational_field_body_entered(_body: PhysicsBody2D):
	if _body is Player:
		player = _body
		check_distance = true

func _on_gravitational_field_body_exited(_body: PhysicsBody2D):
	if _body is Player:
		check_distance = false
