class_name SubArea
extends Area2D

@export var clickable_highlight: ClickableHighlight

var can_exit_sub_area: bool = true

func _ready() -> void:
	if clickable_highlight:
		clickable_highlight.was_clicked.connect(_on_clicked)

func deactivate():
	pass

func _on_clicked():
	pass
