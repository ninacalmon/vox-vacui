extends Control

var cautious_text: String = "CUIDADO!
DÊ MEIA VOLTA
VOCÊ ESTÁ QUASE FORA DO ALCANÇE DE SUA NAVE MÃE
(você será teleportado e perderá fragmentos)"

var fuel_text: String = "Seu combustível está acabando!
Garanta seus fragmentos e volte para a nave mãe."

var mothership_text: String = "Deseja voltar para a nave mãe?"

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	rich_text_label.self_modulate = Color(1, 1, 1, 0)
	rich_text_label.hide()

	EventBus.player_almost_out_of_bounds.connect(_on_player_almost_out_of_bounds)
	EventBus.player_back_in_bounds.connect(_on_player_back_in_bounds)
	EventBus.almost_out_of_fuel.connect(_on_almost_out_of_fuel)
	EventBus.mothership_entrance_entered.connect(mothership_entrance_entered)
	EventBus.mothership_entrance_exited.connect(mothership_entrance_exited)

## DAY 3 ======================================
	if StatsManager.day == 3:
		mothership_text = "Traga o corpo d'A Matriarca para retornar à nave mãe."
## ===============================

func mothership_entrance_entered():
	rich_text_label.text = mothership_text
	show_warning()

func mothership_entrance_exited():
	hide_warning()

func show_warning():
	rich_text_label.self_modulate = Color(1, 1, 1, 0)
	rich_text_label.show()

	var tween = create_tween()
	tween.tween_property(rich_text_label, "self_modulate", Color(1, 1, 1, 1), 0.2)

func hide_warning():
	var tween = create_tween()
	tween.tween_property(rich_text_label, "self_modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished

	rich_text_label.hide()

func _on_player_almost_out_of_bounds():
	rich_text_label.text = cautious_text
	show_warning()

func _on_player_back_in_bounds():
	hide_warning()

func _on_almost_out_of_fuel():
	rich_text_label.text = fuel_text
	show_warning()
	await get_tree().create_timer(5).timeout
	hide_warning()
