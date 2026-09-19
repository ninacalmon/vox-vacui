class_name DoorClosed
extends ActionExecutor

@onready var shake_module: ShakeModule = $ShakeModule


func start():
	current_state = States.FREE
	was_freed.emit()

	if StatsManager.day != 3:

		HandsEventBus.not_yet.emit()
		PopUpSystem.show_text("Não está na hora ainda.", 1.5)
		shake_module.shake(main_spr, 0.2, 0.6)

	else:

		Globals.next_scene_path = "res://scenes/cutscenes/cutscene_final2.tscn"
		LevelTransition.change_scene_to("res://scenes/cutscenes/cutscene_final.tscn")


func finish():
	pass
