class_name Interactable
extends Node2D

@export var requires_energy: bool = true
enum States {IDLE, WAITING, ACTING}

var action_exc: ActionExecutor
var pcam: PhantomCamera2D
## default priority for ACTIVE Interactable PCams is 1000.
## for DISABLED ones are 0.
## for ACTIVE Action Executor PCams is 2000 as they need to override Interactable's.

var main_spr: Sprite2D
var times_used: int

var current_state: States:
	set(value):
		current_state = value
		change_state(value)


func _ready() -> void:
	for child in get_children():
		if child is PhantomCamera2D:
			pcam = child
		elif child is ActionExecutor:
			action_exc = child

	current_state = States.IDLE

	action_exc.was_freed.connect(_on_action_exec_freed)


func change_state(new_state: States):
	match new_state:
		States.IDLE:
			highlight(false)
		States.WAITING:
			highlight(true)
		States.ACTING:
			highlight(false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

	if (event.is_action_pressed("confirm")
	and current_state == States.WAITING):

		if requires_energy and not Globals.spaceship_energy:
			HandsEventBus.not_yet.emit()
			if not StatsManager.day == 3:
				PopUpSystem.show_text(action_exc.energy_message)
			return


		action_exc.start()
		current_state = States.ACTING
	
	if (event.is_action_pressed("return")
	and current_state == States.ACTING
	and action_exc.current_state == action_exc.States.FREE):

		action_exc.finish()
		current_state = States.WAITING


func highlight(_bool: bool):
	action_exc.main_spr.set_instance_shader_parameter("enabled", _bool)


func _on_action_exec_freed():
	action_exc.finish()
	current_state = States.WAITING
