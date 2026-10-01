class_name ShakeModule
extends Node ## AI vvvvvvv

var time := 0.0

# Per-target data
var targets := {}

func _process(delta):
	time += delta

	for target in targets.keys():
		if not is_instance_valid(target):
			targets.erase(target)
			continue

		var data = targets[target]
		data["time_left"] -= delta

		if data["time_left"] <= 0:
			# Restore
			target.position = data["original_position"]
			target.rotation = data["original_rotation"]
			targets.erase(target)
			continue

		var strength = data["strength"]

		# Position shake
		var offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * strength

		target.position = data["original_position"] + offset

		# Rotation shake (smooth)
		target.rotation = data["original_rotation"] + sin(time * 50.0) * 0.05 * strength

func shake(target: Node2D, duration := 0.4, strength := 10.0):
	if not is_instance_valid(target):
		return

	# Store original state
	targets[target] = {
		"time_left": duration,
		"duration": duration,
		"strength": strength,
		"original_position": target.position,
		"original_rotation": target.rotation,
	}

	# Tween strength separately (optional but nice)
	var tween = create_tween()
	tween.tween_method(
		func(value):
			if target in targets:
				targets[target]["strength"] = value,
		strength,
		0.0,
		duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
