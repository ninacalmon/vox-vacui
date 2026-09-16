class_name Interactable
extends Node2D

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


#func _input(event: InputEvent) -> void:
	#if not current_state == States.WAITING:
		#return
#
	#if event.is_action_pressed("confirm"):
		#current_state = States.ACTING
		#



func highlight(_bool: bool):
	main_spr.set_instance_shader_parameter("enabled", _bool)
	print("rodei ", self, _bool)
