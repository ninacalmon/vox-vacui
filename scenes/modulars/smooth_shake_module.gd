class_name SmoothShake
extends Node #AI vvvvvvv

# Stores per-target shake data
var targets := {}

func _process(delta: float) -> void:
	for target in targets.keys():
		if not is_instance_valid(target):
			targets.erase(target)
			continue

		var data = targets[target]
		data["time_left"] -= delta

		# End of shake → restore position
		if data["time_left"] <= 0.0:
			target.position = data["original_position"]
			targets.erase(target)
			continue

		# --- typed values (avoid Variant issues)
		var time_left: float = data["time_left"]
		var duration: float = data["duration"]
		var base_strength: float = data["strength"]

		# progress (0 → 1)
		var t: float = 1.0 - (time_left / duration)

		# ✨ choose behavior
		var current_strength: float

		if data.has("mode") and data["mode"] == "peak":
			var peak_shift: float = data.get("peak_shift", 0.7)
			var shaped_t: float = pow(t, peak_shift)
			current_strength = base_strength * sin(shaped_t * PI)
		else:
			# original falloff
			var falloff: float = pow(1.0 - t, 3)
			current_strength = base_strength * falloff

		# 💥 dynamic sharpness (violent → smooth)
		var sharpness: float = lerp(30.0, 6.0, t)

		# 🎯 more chaos at start, calmer at end
		var randomness: float = lerp(0.7, 0.05, t)
		if randf() < randomness:
			data["target_offset"] = Vector2(
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0)
			) * current_strength

		# ⚡ snappy movement that softens over time
		data["current_offset"] = data["current_offset"].lerp(
			data["target_offset"],
			sharpness * delta
		)

		target.position = data["original_position"] + data["current_offset"]

func shake(target: Node2D, duration: float = 0.4, strength: float = 10.0):
	if not is_instance_valid(target):
		return

	targets[target] = {
		"time_left": duration,
		"duration": duration,
		"strength": strength,
		"original_position": target.position,
		"current_offset": Vector2.ZERO,
		"target_offset": Vector2.ZERO,
	}

# ✨ NEW: peak shake with shift control
func shake_peak(
	target: Node2D, duration: float = 0.6, strength: float = 12.0, peak_shift: float = 0.7
):
	if not is_instance_valid(target):
		return

	targets[target] = {
		"time_left": duration,
		"duration": duration,
		"strength": strength,
		"original_position": target.position,
		"current_offset": Vector2.ZERO,
		"target_offset": Vector2.ZERO,
		"mode": "peak",
		"peak_shift": peak_shift
	}
