extends Node

@export var player: Player

@export var fuel_progress: ProgressBar

func _ready() -> void:

	for p in PowerUps.queued_power_ups_array:
		apply_power_up(p)

func apply_power_up(power_up: String):
	match power_up:
		"Impulse":
			Globals.player_burst_speed *= 2
		"Fuel":
			fuel_progress.max_fuel *= 1.5
			fuel_progress.max_value = fuel_progress.max_fuel
			fuel_progress.value = fuel_progress.max_value
