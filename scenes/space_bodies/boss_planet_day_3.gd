extends BodySetup

@export var _rotate: bool = true

@export var rotation_speed: float = 0.05

@onready var boss: Boss

@onready var breaking_particles: GPUParticles2D = $BreakingParticles

@onready var smooth_shake: SmoothShake = $SmoothShake

@onready var break_sfx: AudioStreamPlayer = $BreakSFX

@onready var break_small_sfx: AudioStreamPlayer = $BreakSmallSFX

##MY POSITIONNNNNNNNNNNNNNNN: (-361.0, -2045.0)
func _ready() -> void:
	boss = get_tree().get_first_node_in_group("Boss_Group")
	#boss.add_collision_exception_with(self)

	##setup
	if gravitational_field:
		gravitational_field.initialize()
	if body_randomizer:
		body_randomizer.initialize(sprite, collision)

	EventBus.start_planet_break.connect(start_cutscene)

func _process(delta: float) -> void:
	linear_velocity = Vector2.ZERO

	if _rotate:
		sprite.rotation += rotation_speed * delta

func start_cutscene():
	 ## SENHA BOSSSSSSSSSSSSSSS
	var duration: float = 6
	smooth_shake.shake_peak(sprite, duration, 12)
	play_break_sound()

	await get_tree().create_timer(duration * 0.1).timeout


	var tween = create_tween()
	tween.tween_property(breaking_particles, "amount_ratio", 1, duration * 0.6)
	tween.tween_property(breaking_particles, "amount_ratio", 0, duration * 0.3)

	await get_tree().create_timer(duration * 0.7).timeout

	EventBus.vibrate.emit(4)
	boss.activate()
	await tween_shader_param(sprite.material, "dissolve_value", 1.0, 0.0, 4)

	#boss.cutscene_finished.emit()

	call_deferred("queue_free")

func play_break_sound():
	for i in 8:
		break_small_sfx.pitch_scale += i * 0.001
		break_small_sfx.volume_db += 1 * 0.1
		SFXManager.play_sound(break_small_sfx)
		await get_tree().create_timer(0.7).timeout

func tween_shader_param(
	mat: ShaderMaterial, param: String, from: float, to: float, duration: float
):
	var _tween = create_tween()
	_tween.tween_method(
		func(value):
			mat.set_shader_parameter(param, value),
		from, to, duration
	)
	await _tween.finished
