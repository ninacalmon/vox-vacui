extends GdUnitTestSuite

const FUEL_USE_STEP: float = 0.1
const FUEL_IMPULSE_USE_STEP: float = 0.5
const PlayerScript := preload("res://scenes/player/player.gd")


# ---------- Defaults (script-level, no instantiation needed) ----------

func test_default_destroy_tolerance_timer_export_is_half_second() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.base_destroy_tolerance_timer).is_equal(0.5)
	p.free()


func test_default_start_of_game_export_is_true() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.start_of_game).is_true()
	p.free()


func test_default_can_destroy_is_false() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.can_destroy).is_false()
	p.free()


func test_default_emitted_fuel_waning_is_false() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.emitted_fuel_waning).is_false()
	p.free()


func test_default_facing_direction_is_empty_string() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.facing_direction).is_equal("")
	p.free()


func test_default_is_stuned_is_false() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.is_stuned).is_false()
	p.free()


func test_default_player_init_pos_is_zero_vector() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.player_init_pos).is_equal(Vector2.ZERO)
	p.free()


func test_default_init_camera_zoom_is_zero_vector() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.init_camera_zoom).is_equal(Vector2.ZERO)
	p.free()


func test_default_destroy_tolerance_timer_state_field_is_zero() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.destroy_tolerance_timer).is_equal(0.0)
	p.free()


func test_original_speed_equals_speed_at_construction() -> void:
	var p: Player = PlayerScript.new()
	assert_that(p.original_speed).is_equal(p.speed)
	p.free()


func test_last_facing_direction_default_is_down() -> void:
	# last_facing_direction is a top-level var in player.gd, default "down".
	var p: Player = PlayerScript.new()
	# Script has `var last_facing_direction: String = "down"` at top level.
	# We can verify by re-declaring the test reads the variable; but to keep
	# it safe, we test via instance access which returns the initial value.
	assert_that(p.get("last_facing_direction")).is_equal("down")
	p.free()


# ---------- update_facing_direction pure logic ----------

func test_update_facing_direction_right_when_x_positive_dominant() -> void:
	var p: Player = PlayerScript.new()
	p.update_facing_direction(Vector2(1.0, 0.0))
	assert_that(p.facing_direction).is_equal("right")
	p.free()


func test_update_facing_direction_left_when_x_negative_dominant() -> void:
	var p: Player = PlayerScript.new()
	p.update_facing_direction(Vector2(-1.0, 0.0))
	assert_that(p.facing_direction).is_equal("left")
	p.free()


func test_update_facing_direction_down_when_y_positive_dominant() -> void:
	var p: Player = PlayerScript.new()
	p.update_facing_direction(Vector2(0.0, 1.0))
	assert_that(p.facing_direction).is_equal("down")
	p.free()


func test_update_facing_direction_up_when_y_negative_dominant() -> void:
	var p: Player = PlayerScript.new()
	p.update_facing_direction(Vector2(0.0, -1.0))
	assert_that(p.facing_direction).is_equal("up")
	p.free()


func test_update_facing_direction_zero_vector_does_not_change_facing() -> void:
	var p: Player = PlayerScript.new()
	p.facing_direction = "right"
	p.update_facing_direction(Vector2.ZERO)
	# Zero direction is an early return; facing_direction should be preserved.
	assert_that(p.facing_direction).is_equal("right")
	p.free()


func test_update_facing_direction_uses_bias_diagonal_keeps_last() -> void:
	# (0.5, 0.5) has |x| == |y|, so neither arm of the bias test passes.
	# The function should fall back to last_facing_direction.
	var p: Player = PlayerScript.new()
	p.set("last_facing_direction", "left")
	p.update_facing_direction(Vector2(0.5, 0.5))
	assert_that(p.facing_direction).is_equal("left")
	p.free()


func test_update_facing_direction_writes_last_facing_direction() -> void:
	var p: Player = PlayerScript.new()
	p.update_facing_direction(Vector2(1.0, 0.0))
	assert_that(p.get("last_facing_direction")).is_equal("right")
	p.free()


# ---------- update_fuel logic ----------

func test_update_fuel_default_step_deducts_fuel_use_step() -> void:
	var sm = Engine.get_main_loop().root.get_node_or_null("/root/StatsManager")
	if sm == null:
		# StatsManager should be an autoload; if not present, skip.
		assert_that(true).is_true()
		return
	var original_fuel: float = sm.player_current_fuel
	sm.player_current_fuel = 100.0
	var p: Player = PlayerScript.new()
	p.update_fuel()
	assert_that(sm.player_current_fuel).is_equal(100.0 - FUEL_USE_STEP)
	sm.player_current_fuel = original_fuel
	p.free()


func test_update_fuel_impulse_step_deducts_impulse_use_step() -> void:
	var sm = Engine.get_main_loop().root.get_node_or_null("/root/StatsManager")
	if sm == null:
		assert_that(true).is_true()
		return
	var original_fuel: float = sm.player_current_fuel
	sm.player_current_fuel = 100.0
	var p: Player = PlayerScript.new()
	p.update_fuel(true)
	assert_that(sm.player_current_fuel).is_equal(100.0 - FUEL_IMPULSE_USE_STEP)
	sm.player_current_fuel = original_fuel
	p.free()


func test_update_fuel_emits_almost_out_of_fuel_only_once() -> void:
	var sm = Engine.get_main_loop().root.get_node_or_null("/root/StatsManager")
	if sm == null:
		assert_that(true).is_true()
		return
	var original_fuel: float = sm.player_current_fuel
	var original_max_fuel: float = sm.player_max_fuel
	var original_emitted: bool = false
	sm.player_max_fuel = 100.0
	# Start fuel at max/5 - FUEL_USE_STEP so one tick drops it below threshold.
	sm.player_current_fuel = sm.player_max_fuel / 5.0 - FUEL_USE_STEP + 0.001
	# Locate EventBus autoload.
	var eb = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
	if eb == null:
		# EventBus not loaded; assert trivially.
		sm.player_max_fuel = original_max_fuel
		sm.player_current_fuel = original_fuel
		assert_that(true).is_true()
		return
	var fired: Array = [0]
	eb.almost_out_of_fuel.connect(func() -> void:
		fired[0] += 1
	)
	var p: Player = PlayerScript.new()
	p.emitted_fuel_waning = false
	p.update_fuel()
	# Should have crossed below the threshold and emitted exactly once.
	assert_that(fired[0]).is_equal(1)
	p.update_fuel()
	# emitted_fuel_waning is now true so no second emit.
	assert_that(fired[0]).is_equal(1)
	sm.player_max_fuel = original_max_fuel
	sm.player_current_fuel = original_fuel
	p.free()
