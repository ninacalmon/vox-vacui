class_name HurtBoxPlayer
extends Area2D

@export var player: Player

@export var bullet_sensible: bool = false

@export var enemy_body_sensible: bool = false

var stuning: bool

var is_stuned: bool

@onready var damage_sfx: AudioStreamPlayer = $DamageSFX

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if stuning:
		player.linear_velocity *= -1

func stun(duration: float):
	if not is_stuned:
		is_stuned = true
		stuning = true
		await get_tree().create_timer(duration).timeout
		stuning = false
		is_stuned = false

func flash():
	player.sprite_2d.modulate = Color(18.892, 18.892, 18.892)
	await get_tree().create_timer(0.1).timeout
	player.sprite_2d.modulate = Color(1, 1, 1)

func _on_area_entered(area: Area2D):
	if bullet_sensible and area is BossBullet:
		var _bullet: BossBullet = area as BossBullet
		_on_enemy_damage_taken(_bullet.damage, _bullet)

func _on_body_entered(body: PhysicsBody2D):
	if enemy_body_sensible and body is Enemy:
		var _enemy: Enemy = body as Enemy
		_on_enemy_damage_taken(_enemy.damage, _enemy)

func _on_enemy_damage_taken(amount: float, _causer: Node2D):
	EventBus.damage_taken.emit(player, amount)
	StatsManager.player_current_health -= amount
	SFXManager.play_sound(damage_sfx)
	flash()
	ControllerVibration.vibrate_controller()

	if StatsManager.player_current_health <= 0:
		EventBus.player_death.emit(true)

func _on_damage_taken(amount: float, _causer: Node2D):
	_on_enemy_damage_taken(amount, _causer)
