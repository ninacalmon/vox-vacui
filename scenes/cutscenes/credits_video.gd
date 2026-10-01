extends VideoStreamPlayer

func _ready() -> void:
	Globals.next_scene_path = "res://scenes/levels/menus/menu.tscn"
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(2).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.7, 0.7, 0.7), 3)
