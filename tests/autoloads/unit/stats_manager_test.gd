extends GdUnitTestSuite

const STATS_MANAGER_SCRIPT := "res://autoloads/stats_manager.gd"

func test_default_values_on_new_instance() -> void:
	var sm = load(STATS_MANAGER_SCRIPT).new()
	assert_that(sm.day).is_equal(0)
	assert_that(sm.resources_needed).is_equal(50)
	assert_that(sm.current_resources).is_equal(0)
	assert_that(sm.player_has_cadaver).is_false()
	assert_that(sm.player_current_bullet).is_equal("res://scenes/bullets/basic_bullet.tscn")
	assert_that(sm.player_have_perfurator).is_true()

func test_base_life_stats_constants() -> void:
	var sm = load(STATS_MANAGER_SCRIPT).new()
	assert_that(sm.PLAYER_MAX_HEALTH).is_equal(100.0)
	assert_that(sm.PLAYER_MAX_FUEL).is_equal(550.0)
	assert_that(sm.player_max_health).is_equal(100.0)
	assert_that(sm.player_max_fuel).is_equal(550.0)
	assert_that(sm.player_current_health).is_equal(100.0)
	assert_that(sm.player_current_fuel).is_equal(550.0)

func test_base_movement_stats_defaults() -> void:
	var sm = load(STATS_MANAGER_SCRIPT).new()
	assert_that(sm.PLAYER_SPEED).is_equal(700.0)
	assert_that(sm.PLAYER_IMPULSE_SPEED).is_equal(1000.0)
	assert_that(sm.PLAYER_MAX_VELOCITY).is_equal(1000.0)
	assert_that(sm.PLAYER_MAX_TURN).is_equal(0.01)
	assert_that(sm.PLAYER_IMPULSE_COOLDOWN_DURATION).is_equal(3.0)

func test_power_up_levels_default_to_zero() -> void:
	var sm = load(STATS_MANAGER_SCRIPT).new()
	var levels: Dictionary = sm.PowerUpsLevels
	assert_that(levels.has("Impulse")).is_true()
	assert_that(levels.has("Fuel")).is_true()
	assert_that(levels.has("Teleport")).is_true()
	assert_that(levels["Impulse"]["current_level"]).is_equal(0)
	assert_that(levels["Impulse"]["max_level"]).is_equal(3)
	assert_that(levels["Teleport"]["max_level"]).is_equal(1)

func test_current_resources_clamps_to_zero() -> void:
	var sm = load(STATS_MANAGER_SCRIPT).new()
	sm.current_resources = -10
	assert_that(sm.current_resources).is_equal(0)
	sm.current_resources = 25
	assert_that(sm.current_resources).is_equal(25)

func test_reset_game_state_restores_defaults() -> void:
	var sm = load(STATS_MANAGER_SCRIPT).new()
	sm.day = 2
	sm.resources_needed = 999
	sm.current_resources = 10
	sm.player_has_cadaver = true
	sm.player_current_bullet = "res://other.tscn"
	sm.player_max_health = 5.0
	sm.player_max_fuel = 5.0
	sm.player_speed = 5.0

	sm.reset_game_state()

	assert_that(sm.day).is_equal(0)
	assert_that(sm.resources_needed).is_equal(50)
	assert_that(sm.current_resources).is_equal(0)
	assert_that(sm.player_has_cadaver).is_false()
	assert_that(sm.player_current_bullet).is_equal("res://scenes/bullets/basic_bullet.tscn")
	assert_that(sm.player_max_health).is_equal(100.0)
	assert_that(sm.player_max_fuel).is_equal(550.0)
	assert_that(sm.player_speed).is_equal(700.0)
	assert_that(sm.player_current_health).is_equal(sm.player_max_health)
	assert_that(sm.player_current_fuel).is_equal(sm.player_max_fuel)
	assert_that(sm.PowerUpsLevels["Impulse"]["current_level"]).is_equal(0)
	assert_that(sm.PowerUpsLevels["Fuel"]["current_level"]).is_equal(0)
	assert_that(sm.PowerUpsLevels["Teleport"]["current_level"]).is_equal(0)
