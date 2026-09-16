class_name Interactable
extends Node2D

@export var requires_energy: bool = true
enum States {IDLE, WAITING, ACTING}

var action_exc: ActionExecutor
var pcam: PhantomCamera2D

var main_spr: Sprite2D

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
		elif child is Sprite2D:
			main_spr = child

	current_state = States.IDLE


func change_state(new_state: States):
	match new_state:
		States.IDLE:
			highlight(false)
		States.WAITING:
			highlight(true)
		States.ACTING:
			pass


func _input(event: InputEvent) -> void:
	if not current_state == States.WAITING:
		return

	if (event.is_action_pressed("confirm")
	and current_state == States.WAITING):

		if requires_energy and not Globals.has_energy_in_spaceship:
			HandsEventBus.not_yet.emit()
			if not StatsManager.day == 3:
				PopUpSystem.show_text(action_exc.energy_message)
			return

		current_state = States.ACTING
		action_exc.start()

	if (event.is_action_pressed("return")
	and current_state == States.WAITING
	and action_exc.current_state == action_exc.States.FREE):

		action_exc.finish()


func highlight(_bool: bool):
	main_spr.set_instance_shader_parameter("enabled", _bool)
	print("rodei ", self, _bool)
