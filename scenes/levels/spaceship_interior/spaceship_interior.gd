extends Node2D

@onready var matriarch_parallax: Parallax2D = $MatriarchParallax

func _ready() -> void:
	matriarch_parallax.visible = StatsManager.day == 3

	await get_tree().create_timer(1).timeout
	if StatsManager.day != 3:
		PopUpSystem.show_text("A nave está sem energia... Precisa de mais fragmentos... De novo.", 3)
	elif StatsManager.day == 3:
		PopUpSystem.show_text("Finalmente... o dia.... chegou...", 3)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
