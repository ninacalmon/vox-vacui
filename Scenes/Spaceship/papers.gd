class_name Papers
extends ActionExecutor


func start():
	current_state = States.FREE
	pcam.set_priority(2000)


func finish():
	current_state = States.FREE
	pcam.set_priority(0)
