class_name VelocityControlDisplay
extends VBoxContainer

@export var arrow: Node2D

@export var km_label: RichTextLabel

@export var max_speed: float = 1000.0

var arrow_colors: Array[Color] = [
	Color(1.0, 1.0, 1.0),
	Color(1.0, 0.7, 0.0),
	Color(0.7, 0.0, 0.0),
	Color(0.2, 0.0, 0.4)
]

func _process(_delta: float) -> void:
	if not arrow or not km_label:
		return

	var speed = StatsManager.player_current_linear_velocity.length()
	var t = clamp(speed / max_speed, 0.0, 1.0)

	arrow.look_at(arrow.global_position + StatsManager.player_current_linear_velocity)

	arrow.modulate = get_gradient_color(t)

	km_label.text = "%d m/s" %speed

func get_gradient_color(t: float) -> Color:
	var count = arrow_colors.size() - 1
	var scaled = t * count

	var index = int(floor(scaled))
	var next_index = min(index + 1, count)

	var local_t = scaled - index

	return arrow_colors[index].lerp(arrow_colors[next_index], local_t)
