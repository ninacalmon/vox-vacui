class_name EnemyVisibleOnScreen
extends VisibleOnScreenNotifier2D

func _ready() -> void:
	screen_entered.connect(_on_enemy_entered_screen)
	screen_exited.connect(_on_enemy_exited_screen)

func _exit_tree():
	EventBus.enemy_off_screen.emit()

func _on_enemy_entered_screen():
	EventBus.enemy_on_screen.emit()

func _on_enemy_exited_screen():
	EventBus.enemy_off_screen.emit()
