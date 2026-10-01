class_name MapControl
extends Node2D

@export var player: Player

@export var camera: Camera2D

@export var safe_area_radius_multiply: float = 5

var map_size: Vector2

var rect: Rect2

@onready var safe_area: Area2D = $SafeArea

@onready var safe_area_shape: CollisionShape2D = $SafeArea/SafeAreaShape

@onready var almost_out_area: Area2D = $AlmostOutArea

@onready var almost_out_area_shape: CollisionShape2D = $AlmostOutArea/AlmostOutAreaShape

func _ready() -> void:
	var new_circle_shape: CircleShape2D = safe_area_shape.shape.duplicate()
	new_circle_shape.radius = 1000 * safe_area_radius_multiply
	safe_area_shape.shape = new_circle_shape

	var new_circle_shape2: CircleShape2D = almost_out_area_shape.shape.duplicate()
	new_circle_shape2.radius = new_circle_shape.radius * 0.7
	almost_out_area_shape.shape = new_circle_shape2

	safe_area.body_exited.connect(_on_safe_area_exited)
	almost_out_area.body_exited.connect(_on_almost_out_area_body_exited)
	almost_out_area.body_entered.connect(_on_almost_out_area_body_entered)

func _on_safe_area_exited(body: RigidBody2D):
	if body is Player and not Globals.changing_scene:
		EventBus.player_out_of_bounds.emit()

func _on_almost_out_area_body_exited(body: RigidBody2D):
	if body is Player:
		EventBus.player_almost_out_of_bounds.emit()

func _on_almost_out_area_body_entered(body: RigidBody2D):
	if body is Player:
		EventBus.player_back_in_bounds.emit()
