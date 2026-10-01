extends Node2D

@export var player: Player

var has_died: bool

@onready var player_death_particles: GPUParticles2D = $PlayerDeathParticles

@onready var death_sfx: AudioStreamPlayer = $DeathSFX

func _ready() -> void:
	EventBus.player_death.connect(_on_player_death_signaled)

func _on_player_death_signaled(explode: bool):
	if has_died:
		return
	has_died = true
	var wait_time: float = player_death_particles.lifetime * 1.8
	if not explode:
		wait_time *= 0.5
	Globals.is_cutscene = true
	SFXManager.play_sound(death_sfx)
	player.linear_velocity = Vector2.ZERO
	player.set_deferred("freeze", true)
	player.hurt_box_player.collision_shape_2d.disabled = true
	if explode:
		player_death_particles.emitting = true
	EventBus.vibrate.emit(3)
	await get_tree().create_timer(player_death_particles.lifetime / 2).timeout
	player.sprite_2d.hide()
	await get_tree().create_timer(wait_time).timeout
	Globals.player_died()
