extends GdUnitTestSuite

const POWER_UPS_SCRIPT := "res://autoloads/power_ups.gd"

func _make():
	return load(POWER_UPS_SCRIPT).new()

func test_initial_levels_are_zero() -> void:
	var pu = _make()
	assert_that(pu.get_current_level("Impulse")).is_equal(0)
	assert_that(pu.get_current_level("Fuel")).is_equal(0)
	assert_that(pu.get_current_level("Teleport")).is_equal(0)
	assert_that(pu.get_current_level("Health")).is_equal(0)
	assert_that(pu.get_current_level("Propulsors")).is_equal(0)
	assert_that(pu.get_current_level("Bullet")).is_equal(0)

func test_add_current_level_increments_each_power_up() -> void:
	var pu = _make()
	pu.add_current_level("Impulse")
	pu.add_current_level("Impulse")
	assert_that(pu.get_current_level("Impulse")).is_equal(2)
	assert_that(pu.get_current_level("Fuel")).is_equal(0)

	pu.add_current_level("Fuel")
	assert_that(pu.get_current_level("Fuel")).is_equal(1)

	pu.add_current_level("Teleport")
	assert_that(pu.get_current_level("Teleport")).is_equal(1)

	pu.add_current_level("Health")
	assert_that(pu.get_current_level("Health")).is_equal(1)

	pu.add_current_level("Propulsors")
	assert_that(pu.get_current_level("Propulsors")).is_equal(1)

	pu.add_current_level("Bullet")
	assert_that(pu.get_current_level("Bullet")).is_equal(1)

func test_get_current_level_unknown_returns_zero() -> void:
	var pu = _make()
	pu.add_current_level("Impulse")
	assert_that(pu.get_current_level("DoesNotExist")).is_equal(0)

func test_reset_game_state_zeroes_all_levels() -> void:
	var pu = _make()
	pu.add_current_level("Impulse")
	pu.add_current_level("Fuel")
	pu.add_current_level("Teleport")
	pu.add_current_level("Health")
	pu.add_current_level("Propulsors")
	pu.add_current_level("Bullet")
	pu.reset_game_state()
	assert_that(pu.get_current_level("Impulse")).is_equal(0)
	assert_that(pu.get_current_level("Fuel")).is_equal(0)
	assert_that(pu.get_current_level("Teleport")).is_equal(0)
	assert_that(pu.get_current_level("Health")).is_equal(0)
	assert_that(pu.get_current_level("Propulsors")).is_equal(0)
	assert_that(pu.get_current_level("Bullet")).is_equal(0)

func test_apply_power_up_impulse_doubles_impulse_speed() -> void:
	var orig: float = StatsManager.player_impulse_speed
	var pu = _make()
	pu.apply_power_up("Impulse")
	assert_that(StatsManager.player_impulse_speed).is_equal(orig * 2)
	StatsManager.player_impulse_speed = orig

func test_apply_power_up_fuel_multiplies_max_fuel() -> void:
	var orig: float = StatsManager.player_max_fuel
	var pu = _make()
	pu.apply_power_up("Fuel")
	assert_that(StatsManager.player_max_fuel).is_equal(orig * 1.5)
	StatsManager.player_max_fuel = orig

func test_apply_power_up_teleport_enables_teleport() -> void:
	var orig: bool = Globals.can_teleport
	var pu = _make()
	Globals.can_teleport = false
	pu.apply_power_up("Teleport")
	assert_that(Globals.can_teleport).is_true()
	Globals.can_teleport = orig

func test_apply_power_up_bullet_switches_to_super_bullet() -> void:
	var orig: String = StatsManager.player_current_bullet
	var pu = _make()
	pu.apply_power_up("Bullet")
	assert_that(StatsManager.player_current_bullet).is_equal("res://scenes/bullets/super_bullet.tscn")
	StatsManager.player_current_bullet = orig

func test_apply_power_up_perfurator_enables_it() -> void:
	var orig: bool = StatsManager.player_have_perfurator
	var pu = _make()
	StatsManager.player_have_perfurator = false
	pu.apply_power_up("Perfurator")
	assert_that(StatsManager.player_have_perfurator).is_true()
	StatsManager.player_have_perfurator = orig
