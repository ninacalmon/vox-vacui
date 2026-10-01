class_name Enemy
extends RigidBody2D

@export var speed: float = 100

@export var max_velocity: float = 400.0

@export var life: float = 4

@export var damage: float = 3

@export var player: Player

@export var wander_speed: float = 30

@export var attack_force: float = 800

@export var attack_distance: float = 80

@export var retreat_time: float = 0.4

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

@onready var hurt_box: Area2D = $HurtBox

@onready var aggro_area: Area2D = $AggroArea

@onready var attack_sfx: AudioStreamPlayer = $AttackSFX
