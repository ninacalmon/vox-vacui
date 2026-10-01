class_name BlackHoleGravitationalField
extends GravitationalField

@onready var event_horizon: Area2D = $EventHorizon

@onready var eh_range: CollisionShape2D = $EventHorizon/EHRange

func _ready() -> void:
	var range_circle: CircleShape2D = _range.shape.duplicate()
	range_circle.radius = owner_body.mass * mass_to_radius_multiply
	_range.shape = range_circle

	# Event horizon = point of no return
	var eh_circle: CircleShape2D = eh_range.shape.duplicate()
	eh_circle.radius = range_circle.radius * 0.3
	eh_range.shape = eh_circle

	area_entered.connect(_on_grav_field_entered_by_area)
	area_exited.connect(_on_grav_field_exited_by_area)
	event_horizon.area_entered.connect(_on_event_horizon_entered)

func _physics_process(_delta: float) -> void:
	for b in body_near:
		apply_gravity(b)

func apply_gravity(near_body: PhysicsBody2D): #AI vvvvvvv
	if near_body == owner_body:
		return

	if not is_instance_valid(near_body):
		return

	var direction = owner_body.global_position - near_body.global_position
	var distance = max(direction.length(), 10.0)

	var dir_normalized = direction.normalized()

	var G = 1000.0

	# your original inverse-square
	var base_force = G * (owner_body.mass * near_body.mass) / (distance * distance)

	# 🔥 extra pull when close (this is the magic)
	var close_boost = 1.0
	if distance < 150.0:
		close_boost += (150.0 - distance) / 150.0 * 2.5
		# ramps up smoothly as you approach center

	var final_force = base_force * close_boost

	# 🌀 FIXED swirl (actually noticeable now)
	var tangent = Vector2(-dir_normalized.y, dir_normalized.x)
	var swirl = tangent * final_force * 0.4

	# combine forces
	var force_on_other = (dir_normalized * final_force) + swirl
	var force_on_self = -dir_normalized * final_force * attraction_received_multiply

	near_body.apply_central_force(force_on_other)
	owner_body.apply_central_force(force_on_self)

func _on_event_horizon_entered(area: GravitationalField):
	var body = area.owner_body
	if body == owner_body:
		return

	if is_instance_valid(body):
		return
