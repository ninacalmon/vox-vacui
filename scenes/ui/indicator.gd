extends Node2D

@export var mothership: Node2D

@export var player: Player

var margin: float = 45.0

var corner_radius: float = 20.0

var last_viewport_size: Vector2 = Vector2.ZERO

var arc_points: int = 8

var smooth_speed: float = 5.0

var path_points: Array = []

var was_visible_on_screen: bool = true

var _mothership_radius: float = 0.0

func _ready():
	if mothership:
		var collision = mothership.get_node_or_null("CollisionShape2D")
		if collision and collision.shape is CircleShape2D:
			_mothership_radius = collision.shape.radius
	if mothership and player:
		build_path_points()

func _process(_delta):
	if not mothership or not player:
		return

	var viewport_size = get_viewport_rect().size
	if viewport_size != last_viewport_size:
		build_path_points()
		last_viewport_size = viewport_size

	var camera_global_pos = Vector2.ZERO
	if player and player.camera:
		camera_global_pos = player.camera.global_position

	var mothership_screen = (Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)
			+ (mothership.global_position - camera_global_pos))
	if Globals.is_cutscene:
		visible = false
		return

	var ms_x = mothership_screen.x
	var ms_y = mothership_screen.y

	var is_visible_on_screen = (
		ms_x - _mothership_radius < viewport_size.x and
		ms_x + _mothership_radius > 0 and
		ms_y - _mothership_radius < viewport_size.y and
		ms_y + _mothership_radius > 0
	)

	var just_left_screen = was_visible_on_screen and not is_visible_on_screen

	visible = not is_visible_on_screen

	if not is_visible_on_screen:
		var closest_point = _get_closest_point(mothership_screen)
		if just_left_screen:
			position = closest_point
			var direction = (mothership_screen - position).normalized()
			rotation = direction.angle() + PI/2
		else:
			position = position.lerp(closest_point, clamp(smooth_speed * get_process_delta_time(), 0.0, 1.0))
			var direction = (mothership_screen - position).normalized()
			var target_rotation = direction.angle() + PI/2
			rotation = lerp_angle(
				rotation, target_rotation,
				clamp(smooth_speed * get_process_delta_time(), 0.0, 1.0)
			)

func build_path_points():
	path_points.clear()
	var vp = get_viewport_rect().size
	var r = corner_radius
	var tl = Vector2(margin, margin)
	var tr = Vector2(vp.x - margin, margin)
	var br = Vector2(vp.x - margin, vp.y - margin)
	var bl = Vector2(margin, vp.y - margin)

	#top edge
	_add_line_points(Vector2(tl.x + r, tl.y), Vector2(tr.x - r, tr.y))

	#top right corner
	_add_arc_points(Vector2(tr.x - r, tr.y + r), -PI/2, 0)

	#right edge
	_add_line_points(Vector2(tr.x, tr.y + r), Vector2(br.x, br.y - r))

	#bottom right corner
	_add_arc_points(Vector2(br.x - r, br.y - r), 0, PI/2)

	#bottom edge
	_add_line_points(Vector2(br.x - r, br.y), Vector2(bl.x + r, bl.y))

	#bottom left connor :o
	_add_arc_points(Vector2(bl.x + r, bl.y - r), PI/2, PI)

	#left edge
	_add_line_points(Vector2(bl.x, bl.y - r), Vector2(tl.x, tl.y + r))

	#top left corner
	_add_arc_points(Vector2(tl.x + r, tl.y + r), PI, 3*PI/2)

func _add_line_points(from: Vector2, to: Vector2):
	var steps = max(2, int(from.distance_to(to) / 10))
	for i in range(steps + 1):
		var t = float(i) / steps
		path_points.append(from.lerp(to, t))

func _add_arc_points(center: Vector2, start_angle: float, end_angle: float):
	for i in range(arc_points + 1):
		var t = float(i) / arc_points
		var angle = lerp(start_angle, end_angle, t)
		var point = center + Vector2(cos(angle), sin(angle)) * corner_radius
		path_points.append(point)

func _get_closest_point(target: Vector2) -> Vector2:
	if path_points.size() == 0:
		return Vector2.ZERO
	var min_dist_sq = INF
	var closest = Vector2.ZERO
	for point in path_points:
		var dist_sq = point.distance_squared_to(target)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest = point
	return closest
