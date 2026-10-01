extends Area2D

@export var tutorial_warning: TutorialControl

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		tutorial_warning.label.text = "Nave mãe.
Deseja entrar?"
		tutorial_warning.show_warning()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		tutorial_warning.hide_warning()
