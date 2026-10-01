extends Node2D

@export var owner_body: RigidBody2D

var velocity_lenght_array: Array[float] = []

var vel_lenght: float

var last_vel_lenght: float

var tolerance: float = 80.0

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	owner_body.body_entered.connect(_on_owner_body_shape_entered)

func _physics_process(_delta: float) -> void:
	vel_lenght = owner_body.linear_velocity.length()
	if velocity_lenght_array.size() > 0 and \
	abs(vel_lenght - velocity_lenght_array.back()) <= tolerance:
		return
	velocity_lenght_array.push_front(vel_lenght)
	if velocity_lenght_array.size() > 5:
		velocity_lenght_array.pop_back()

func emit_particles(damage: float):
	gpu_particles_2d.amount = int(damage * 2)
	gpu_particles_2d.emitting = true

func _on_owner_body_shape_entered(_body: RigidBody2D):
	vel_lenght = owner_body.linear_velocity.length()
	velocity_lenght_array.push_front(vel_lenght)
	if velocity_lenght_array.size() > 5:
		velocity_lenght_array.pop_back()

	if abs(velocity_lenght_array.get(1) - velocity_lenght_array.get(0)) >= tolerance:
		var damage: float = velocity_lenght_array.get(0) / 20
		EventBus.damage_taken.emit(owner_body, damage)
		emit_particles(damage)
