extends AudioStreamPlayer

func _ready() -> void:
	SpaceshipEventBus.player_going_out.connect(_on_player_going_out)
	SpaceshipEventBus.resource_count_finished.connect(_on_resource_count_finished)

func _on_resource_count_finished():
	var original_volume = volume_db
	volume_db = -50
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", original_volume, 2)

func _on_player_going_out():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 0.8)
