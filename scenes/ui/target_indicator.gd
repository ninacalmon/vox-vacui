extends Node2D

@export var radius: float = 40.0
@export var color: Color = Color(1, 1, 1, 0.8)
@export var width: float = 2.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, width)