extends Node2D

@export var target_indicator: Node2D
var current_target: Enemy = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("test_l"):
		handle_lock_input()

	if is_instance_valid(current_target):
		target_indicator.global_position = current_target.global_position

#Find visible enemies
func get_visible_enemies() -> Array:
	var candidates: Array = []
	for enemy in get_tree().get_nodes_in_group("Enemy_Group"):
		if is_instance_valid(enemy) and enemy.visible_notifier.is_on_screen():
			candidates.append(enemy)
	return candidates

#Find nearest enemy
func get_nearest(list: Array) -> Enemy:
	var nearest: Enemy = null
	var nearest_dist: float = INF
	for enemy in list:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy	
	return nearest

#Center target swap
func set_target(new_target: Enemy):
	if is_instance_valid(current_target) and current_target.tree_exited.is_connected(_on_target_died):
		current_target.tree_exited.disconnect(_on_target_died)

	current_target = new_target

	if is_instance_valid(current_target):
		current_target.tree_exited.connect(_on_target_died)
		target_indicator.visible = true
	else:
		target_indicator.visible = false

#Input
func handle_lock_input():
	var visible_enemies = get_visible_enemies()
	if is_instance_valid(current_target):
		visible_enemies.erase(current_target)

	set_target(get_nearest(visible_enemies))

func _on_target_died():
	set_target(get_nearest(get_visible_enemies()))
