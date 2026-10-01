class_name TutorialControl
extends Control

@onready var label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	label.self_modulate = Color(1, 1, 1, 0)
	label.hide()

	await get_tree().create_timer(4).timeout
	start_tutorial()

	#EventBus.player_almost_out_of_bounds.connect(_on_player_almost_out_of_bounds)
	#EventBus.player_back_in_bounds.connect(_on_player_back_in_bounds)
	#EventBus.almost_out_of_fuel.connect(_on_almost_out_of_fuel)
	#EventBus.mothership_entrance_entered.connect(mothership_entrance_entered)
	#EventBus.mothership_entrance_exited.connect(mothership_entrance_exited)

func start_tutorial():
	label.text = "Você está sozinho.
Siga à direita.

Preste atenção às guias do lado inferior esquerdo para conferir os controles."
	show_warning()
	await get_tree().create_timer(5).timeout
	hide_warning()

func show_warning():
	label.self_modulate = Color(1, 1, 1, 0)
	label.show()

	var tween = create_tween()
	tween.tween_property(label, "self_modulate", Color(1, 1, 1, 1), 0.2)

func hide_warning():
	var tween = create_tween()
	tween.tween_property(label, "self_modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished

	label.hide()
