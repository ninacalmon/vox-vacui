class_name CollectableResource
extends BodySetup

@export var speed: float = 300

var collect_offset: float = 10

var following: bool

var target: Node2D

var asteroid_parent: Asteroid = null

var _linear_velocity: Vector2

var _angular_velocity: float

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

@onready var collectiong_sfx: AudioStreamPlayer = $CollectiongSFX

func _ready() -> void:
	if body_randomizer:
		body_randomizer.initialize(sprite, collision)
	if gravitational_field:
		gravitational_field.initialize()
	if gravitational_field_resources:
		gravitational_field_resources.initialize()

func _process(delta: float) -> void:
	var is_on_screen: bool = visible_on_screen_notifier_2d.is_on_screen()
	if not is_on_screen and not freeze:
		storage_vel()
		freeze = true
	#freeze = !visible_on_screen_notifier_2d.is_on_screen()
	elif is_on_screen and freeze:
		freeze = false
		apply_vel()

	if not following or target == null:
		return
	var direction = (target.global_position - global_position).normalized()
	self.global_position += direction * speed * delta

	if self.global_position.distance_to(target.global_position) <= collect_offset:
		collect()

func collect():
	if target is Player:
		EventBus.space_resource_collected.emit()
		SFXManager.play_sound(collectiong_sfx)
		queue_free()

func storage_vel():
	_linear_velocity = linear_velocity
	_angular_velocity = angular_velocity

func apply_vel():
	linear_velocity = _linear_velocity
	angular_velocity = _angular_velocity
