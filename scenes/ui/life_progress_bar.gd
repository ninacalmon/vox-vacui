extends TextureProgressBar

@export var max_hp: float = 100

@export var low_hp_overlay: Sprite2D

var emitted: bool = false

func _ready() -> void:
	low_hp_overlay.modulate.a = 0

	EventBus.damage_taken.connect(_on_damage_taken)
	max_value = StatsManager.player_max_health
	value = StatsManager.player_current_health

func update_overlay():
	if value <= max_hp / 3:
		low_hp_overlay.show()
		var tween = create_tween()
		tween.tween_property(low_hp_overlay, "modulate:a", 0.2, 1)
		if value <= max_hp / 4:
			tween.tween_property(low_hp_overlay, "modulate:a", 0.4, 1)

func _on_damage_taken(damaged: RigidBody2D, _amount: float):
	if damaged is Player:
		await get_tree().process_frame
		value = StatsManager.player_current_health
	update_overlay()
