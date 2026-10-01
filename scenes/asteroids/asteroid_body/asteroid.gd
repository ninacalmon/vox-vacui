class_name Asteroid
extends BodySetup
@export_enum("small", "medium", "big") var asteroid_size = "small"
@export_range(0, 100, 1) var critters_chance_percentage: int

@export var base_endurance: float = 200

@export var minimum_damage: float = 70

@export var minimum_external_damage: float = 160

@export var endur_to_pieces_proportion: float = 8

@export var will_spawn_critters: bool

@export var critters_amount_min: int = 2

@export var critters_amount_max: int = 5

@export var damage_module: DamageModule

@export var broken_piece_scene: PackedScene

@export var enemy_option_array: Array[PackedScene]

@export var palette_options: Array[Texture]

@export var is_fix: bool

var animated_sprite: AnimatedSprite2D

var endurance: float

var first_impact_bonus: float = 1.5

var parent

var original_sprite_scale: Vector2

var original_collision_radius: float

var chosen_palette: Texture

@onready var break_sound: AudioStreamPlayer = $BreakSound

@onready var critter_sound: AudioStreamPlayer = $CritterSound

@onready var particles_pivot: Node2D = $ParticlesPivot

@onready var gpu_particles_2d: GPUParticles2D = $ParticlesPivot/GPUParticles2D

func _ready() -> void:
	## setup
	if gravitational_field:
		gravitational_field.initialize()
	if body_randomizer:
		body_randomizer.initialize(sprite, collision)

	animated_sprite = sprite as AnimatedSprite2D
	animated_sprite.animation = "default"

	original_sprite_scale = sprite.scale
	original_collision_radius = collision.shape.radius

	endurance = base_endurance

	parent = get_parent()

	if damage_module:
		damage_module.damage_taken.connect(_on_damage_taken)

	if palette_options.size() > 0:
		var new_palette = palette_options.pick_random()
		chosen_palette = new_palette
		sprite.material.set_shader_parameter("new_palette", new_palette)

func _process(_delta: float) -> void:
	if is_fix:
		linear_velocity = Vector2.ZERO

func update_sprite():
	if endurance < base_endurance * 0.8 and endurance > base_endurance * 0.5:
		animated_sprite.play("damaged1")
	elif endurance < base_endurance * 0.5:
		animated_sprite.play("damaged2")

func handle_player_damage(damage: float, _player: Player):
	var size_index: int = 0
	match asteroid_size:
		"small": size_index = 1
		"medium": size_index = 2
		"big": size_index = 3
	ControllerVibration.vibrate_controller(size_index, 0.3)
	var bonus_multiplier: float = 1.0
	emit_particles(_player)

	if damage >= base_endurance and endurance == base_endurance:
		bonus_multiplier = first_impact_bonus

	var dict: Dictionary = calculate_damage_and_pieces(damage, bonus_multiplier)
	var actual_damage = dict["actual_damage"]
	var pieces = dict["pieces"]

	endurance -= actual_damage

	break_sound.volume_db = -15
	SFXManager.play_sound(break_sound)

	call_deferred("shed_pieces", pieces)
	if will_spawn_critters:
		spawn_critters(true)

	signal_vibration(bonus_multiplier)

func handle_external_damage(damage: float):
	var dict: Dictionary = calculate_damage_and_pieces(damage)
	var actual_damage = dict["actual_damage"]
	var pieces = dict["pieces"]

	endurance -= actual_damage

	break_sound.volume_db = -22
	SFXManager.play_sound(break_sound)

	call_deferred("shed_pieces", pieces)

func shed_pieces(pieces: int):
	for p in pieces:
		var new_piece: CollectableResource = broken_piece_scene.instantiate()
		new_piece.global_position = global_position \
		+ Vector2(randi_range(-50, 50), randi_range(-50, 50))
		new_piece.asteroid_parent = self
		parent.call_deferred("add_child", new_piece)
	update_sprite()
	scale_down(0.8, 0.2)

func signal_vibration(bonus_multiplier: float):
	var is_first_impact: bool = false

	if bonus_multiplier == first_impact_bonus:
		is_first_impact = true

	var vibration_index: int = 0

	match asteroid_size:
		"small":
			vibration_index = 0

		"medium":
			if not is_first_impact:
				vibration_index = 1
			else: vibration_index = 2

		"big" :
			if not is_first_impact:
				vibration_index = 2
			else: vibration_index = 3

	EventBus.vibrate.emit(vibration_index)

func emit_particles(other: Node2D):
	if other and particles_pivot and gpu_particles_2d:
		particles_pivot.look_at(other.global_position)
		gpu_particles_2d.emitting = true

func spawn_critters(is_player: bool = false):
	var chance = randi_range(0, 100)

	if chance <= critters_chance_percentage:
		var critters_amount = randi_range(critters_amount_min, critters_amount_max)

		for i in critters_amount:
			var new_critter: Enemy = enemy_option_array.pick_random().instantiate()
			new_critter.player = get_tree().get_first_node_in_group("Player_Group")
			new_critter.global_position = global_position \
			+ Vector2(randi_range(-20, 20), randi_range(-20, 20))
			parent.call_deferred("add_child", new_critter)
		if is_player:
			SFXManager.play_sound(critter_sound)

func scale_down(amount: float, duration: float = 0.5):
	var sprite_new_scale = sprite.scale * amount
	var collision_new_scale = collision.scale * amount
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(sprite, "scale", sprite_new_scale, duration)
	tween.parallel().tween_property(collision, "scale", collision_new_scale, duration)
	await tween.finished

## Return value is dictionary with contract { "actual_damage", "pieces" }
func calculate_damage_and_pieces(damage, bonus_multiplier: float = 1.0) -> Dictionary:
	var actual_damage = min(damage, endurance)
	var pieces: int = ceil((actual_damage / endur_to_pieces_proportion) * bonus_multiplier)

	return {
		"actual_damage": actual_damage,
		"pieces": pieces
	}

func _on_damage_taken(damage: float, causer: RigidBody2D):
	if causer is Player:
		if damage > minimum_damage:
			handle_player_damage(damage, causer)
		else: ControllerVibration.vibrate_controller(1)

	if not (causer is Player) and damage > minimum_external_damage:
		handle_external_damage(damage)


	if endurance <= 0:
		await scale_down(0)
		call_deferred("queue_free")
