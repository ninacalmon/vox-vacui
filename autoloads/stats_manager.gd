extends Node

#region Init Consts
const INIT_DAY: int = 0

const INIT_RESOURCES_NEEDED: int = 50

const INIT_CURRENT_RESOURCES: int = 0

const INIT_PLAYER_HAS_CADAVER: bool = false

const INIT_CURRENT_DAY: int = 0

const INIT_DEATH_COUNT: int = 0

const INIT_PLAYER_CURRENT_BULLET: String = "res://scenes/bullets/basic_bullet.tscn"

#region CONST BaseLifeStats
const PLAYER_MAX_HEALTH: float = 100.0

const PLAYER_MAX_FUEL: float = 550.0

const FUEL_USE_STEP: float = 0.1

const FUEL_IMPULSE_USE_STEP: float = 0.5

#endregion
#region CONST BaseMovementStats
const PLAYER_SPEED: float = 700.0

const PLAYER_IMPULSE_SPEED: float = 1000.0

const PLAYER_IMPULSE_COOLDOWN_DURATION: float = 3.0

const PLAYER_BREAK_SPEED: float = 3.0

const PLAYER_MAX_VELOCITY: float = 1000.0

const PLAYER_MAX_TURN: float = 0.01

#endregion
var day: int = 0

#### RESOURCES BANK ####
var resources_needed: int = 50

var current_resources: int = 0:
	set(value):
		current_resources = max(value, 0)

var player_has_cadaver: bool = false

#### POWER UPS ####
var PowerUpsLevels: Dictionary = {
	"Impulse": {
		"current_level": 0,
		"max_level": 3
	},
	"Fuel": {
		"current_level": 0,
		"max_level": 3
	},
	"Teleport": {
		"current_level": 0,
		"max_level": 1
	}
}

##### COUNTERS ####
#### PLAYER CONST BASE STATS ####
var player_current_bullet: String = "res://scenes/bullets/basic_bullet.tscn"

var player_have_perfurator: bool = true

#endregion
#### PLAYER VARIABLE BASE STATS ####
#region var BaseLifeStats
var player_max_health: float = PLAYER_MAX_HEALTH

var player_max_fuel: float = PLAYER_MAX_FUEL

#endregion
#region var BaseMovementStats
var player_speed: float = PLAYER_SPEED

var player_impulse_speed: float = PLAYER_IMPULSE_SPEED

var player_impulse_cooldown_duration: float = PLAYER_IMPULSE_COOLDOWN_DURATION

var player_break_speed: float = PLAYER_BREAK_SPEED

var player_max_velocity: float = PLAYER_MAX_VELOCITY

var player_max_turn: float = PLAYER_MAX_TURN

#endregion
#### PLAYER CURRENT STATS ####
#region CurrentLifeStats
var player_current_health: float = player_max_health

var player_current_fuel: float = player_max_fuel

#endregion
#region CurrentMovementStats
var player_current_linear_velocity: Vector2

#endregion
func reset_game_state() -> void:
	day = INIT_DAY

	resources_needed = INIT_RESOURCES_NEEDED
	current_resources = INIT_CURRENT_RESOURCES
	player_has_cadaver = INIT_PLAYER_HAS_CADAVER

	PowerUpsLevels = {
		"Impulse": {
			"current_level": 0,
			"max_level": 3
		},
		"Fuel": {
			"current_level": 0,
			"max_level": 3
		},
		"Teleport": {
			"current_level": 0,
			"max_level": 1
		}
	}

	#current_day = INIT_CURRENT_DAY
	#death_count = INIT_DEATH_COUNT

	player_current_bullet = INIT_PLAYER_CURRENT_BULLET

	player_max_health = PLAYER_MAX_HEALTH
	player_max_fuel = PLAYER_MAX_FUEL

	player_speed = PLAYER_SPEED
	player_impulse_speed = PLAYER_IMPULSE_SPEED
	player_impulse_cooldown_duration = PLAYER_IMPULSE_COOLDOWN_DURATION
	player_break_speed = PLAYER_BREAK_SPEED
	player_max_velocity = PLAYER_MAX_VELOCITY
	player_max_turn = PLAYER_MAX_TURN

	player_current_health = player_max_health
	player_current_fuel = player_max_fuel

	player_current_linear_velocity = Vector2.ZERO
