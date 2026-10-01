class_name BossTargetedBullet
extends BossBullet

@export var turn_speed: float = 0.5

var target: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	#area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if target and is_instance_valid(target):
		var desired_direction = global_position.direction_to(target.global_position)

		var current_angle = direction.angle()
		var target_angle = desired_direction.angle()

		var angle_diff = wrapf(target_angle - current_angle, -PI, PI)

		var max_turn = turn_speed * delta

		angle_diff = clamp(angle_diff, -max_turn, max_turn)

		var new_angle = current_angle + angle_diff
		direction = Vector2.RIGHT.rotated(new_angle)

	global_position += direction * speed * delta
	rotation = direction.angle()

	lifespan -= delta
	if lifespan <= 0:
		decay_and_delete()

func decay_and_delete():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_2d, "scale", Vector2.ONE * 0.1, 0.5)
	await tween.finished
	call_deferred("queue_free")
