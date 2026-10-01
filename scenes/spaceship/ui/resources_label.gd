extends RichTextLabel

func _ready() -> void:
	hide()
	text = "[b]%d[/b]
fragmentos" %StatsManager.current_resources
	SpaceshipEventBus.resources_spent.connect(_on_resources_spent)

	SpaceshipEventBus.focus_changed.connect(_on_focus_changed)

func flash(what: Control):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(what, "self_modulate", Color(0, 0, 0, 1), 0.02)
	tween.tween_property(what, "self_modulate", Color(0.31, 1.825, 0.0), 0.05)
	tween.tween_property(what, "self_modulate", Color(1, 1, 1, 1), 0.2)

func _on_resources_spent():
	show()
	await get_tree().create_timer(1.5).timeout
	flash(self)
	text = "[b]%d[/b]
fragmentos" %StatsManager.current_resources

func _on_focus_changed(focus: bool, subject: Node2D):
	if focus and subject is Monitor:
		add_theme_font_size_override("normal_font_size", 24)
		add_theme_font_size_override("bold_font_size", 32)
		add_theme_color_override("font_outline_color", Color(0.05, 0.245, 0.0, 1.0))
		add_theme_constant_override("outline_size", 8)
	elif not focus:
		remove_theme_font_size_override("bold_font_size")
		remove_theme_font_size_override("normal_font_size")
		remove_theme_color_override("font_outline_color")
		remove_theme_constant_override("outline_size")
		#modulate = Color.WHITE
