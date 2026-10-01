extends AudioStreamPlayer

func _ready() -> void:
	var original_volume = volume_db
	volume_db = -80
	var tween = create_tween()
	tween.tween_property(self, "volume_db", original_volume, 0.8)
	EventBus.player_wants_to_enter_mothership.connect(_on_player_enters_mothership)

func _on_player_enters_mothership():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 0.8)
