extends RichTextLabel

@export var ButtonsControl: Control

var flicker_chances: float = 0.02

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	_on_menu_selection_changed(1)
	if ButtonsControl:
		ButtonsControl.menu_selection_changed.connect(_on_menu_selection_changed)

func _on_menu_selection_changed(number: int) -> void:
	text = "match " + str(number) + " of 3"

func _on_timer_timeout() -> void:
	if randf() < flicker_chances:
		visible = false
	else:
		visible = true
	pass
