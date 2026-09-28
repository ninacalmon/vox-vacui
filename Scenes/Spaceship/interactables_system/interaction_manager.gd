class_name InteractionManager
extends Node

@export_range(0, 6, 1.0) var starting_idx: int = 1

var inter_array: Array[Interactable]
var current_inter: Interactable
var current_inter_idx: int

var changing_inter: bool = false

func _ready() -> void:
	for child in get_children():
		if child is Interactable:
			inter_array.append(child)

	enable_inter(starting_idx)

	SpaceshipEventBus.snap_ui_left.connect(_on_snap_ui_left)
	SpaceshipEventBus.snap_ui_right.connect(_on_snap_ui_right)


func _input(event: InputEvent) -> void:
	if changing_inter or not current_inter.current_state == current_inter.States.WAITING:
		return
	
	if event.is_action_pressed("ui_left") and is_change_possible(current_inter_idx -1):
		change_inter_to(current_inter_idx -1)
		changing_inter = true

	elif event.is_action_pressed("ui_right") and is_change_possible(current_inter_idx +1):
		change_inter_to(current_inter_idx +1)
		changing_inter = true

	await get_tree().create_timer(0.2).timeout
	changing_inter = false


func is_change_possible(next_idx: int) -> bool:
	if not next_idx >= 0 or not next_idx < inter_array.size():
		return false

	return inter_array[next_idx].current_state == inter_array[next_idx].States.IDLE


func change_inter_to(next_idx: int):
	disable_inter(current_inter_idx)
	enable_inter(next_idx)



func enable_inter(idx: int):
	var inter: Interactable = inter_array[idx]

	inter.pcam.set_priority(1000)
	inter.current_state = inter.States.WAITING

	current_inter = inter_array[idx]
	current_inter_idx = idx


func disable_inter(idx: int):
	var inter: Interactable = inter_array[idx]

	inter.pcam.set_priority(0)
	inter.current_state = inter.States.IDLE


func _on_snap_ui_left():
	if not current_inter.current_state == current_inter.States.WAITING:
		return
	
	if is_change_possible(current_inter_idx -1):
		change_inter_to(current_inter_idx -1)


func _on_snap_ui_right():
	if not current_inter.current_state == current_inter.States.WAITING:
		return
	
	if is_change_possible(current_inter_idx +1):
		change_inter_to(current_inter_idx +1)
