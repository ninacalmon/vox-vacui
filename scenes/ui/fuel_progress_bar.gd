class_name FuelProgressBar
extends TextureProgressBar

var emitted: bool = false

func _ready() -> void:
	EventBus.fuel_used.connect(_on_fuel_used)
	max_value = StatsManager.player_max_fuel
	value = StatsManager.player_current_fuel

func _on_fuel_used():
	value = StatsManager.player_current_fuel

		#EventBus.out_of_fuel.emit()
		#get_tree().reload_current_scene()
