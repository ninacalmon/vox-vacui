class_name PathOrbit
extends Path2D
@export_range(0, 1, 0.001) var initi_progress_ration = 0.0

@export var radius: float = 400

@export var point_count: int = 64

@export var speed: float = 50.0

@export var reverse: bool = false

@export var body_scene: PackedScene

@export var circle_color: Color = Color(0.6, 0.6, 0.6, 0.2)

@export var circle_width: float = 1

@onready var path_follow_2d: PathFollowOrbit = $PathFollow2D

func _ready() -> void:
	if body_scene:
		var new_body = body_scene.instantiate()
		path_follow_2d.add_child(new_body)
	path_follow_2d.reverse = reverse
	path_follow_2d.speed = speed
	curve.clear_points()
	curve = make_circle_path(radius, point_count)
	path_follow_2d.progress_ratio = initi_progress_ration

	queue_redraw()

func _draw() -> void:
	var points: PackedVector2Array = []

	for i in range(point_count + 1):
		var angle = (TAU * i) / point_count
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))

	draw_polyline(points, circle_color, circle_width, true)

func make_circle_path(_radius: float, _point_count: int) -> Curve2D:
	var _curve = Curve2D.new()

	for i in range(_point_count):
		var angle = (TAU * i) / _point_count
		var x = cos(angle) * _radius
		var y = sin(angle) * _radius

		_curve.add_point(Vector2(x, y))

	_curve.add_point(_curve.get_point_position(0))

	return _curve
