extends GdUnitTestSuite

const GLOBALS_SCRIPT := "res://autoloads/globals.gd"

func test_default_values() -> void:
	var g = load(GLOBALS_SCRIPT).new()
	assert_that(g.can_teleport).is_false()
	assert_that(g.changing_scene).is_false()
	assert_that(g.next_scene_path).is_equal("res://scenes/levels/menus/menu.tscn")
	assert_that(g.has_energy_in_spaceship).is_false()

func test_reset_game_state_restores_defaults() -> void:
	var g = load(GLOBALS_SCRIPT).new()
	g.can_teleport = true
	g.is_cutscene = true
	g.changing_scene = true
	g.fake_mouse_input = true
	g.is_showing_confirmation = true
	g.next_scene_path = "res://other.tscn"
	g.reset_game_state()
	assert_that(g.can_teleport).is_false()
	assert_that(g.is_cutscene).is_false()
	assert_that(g.changing_scene).is_false()
	assert_that(g.fake_mouse_input).is_false()
	assert_that(g.is_showing_confirmation).is_false()
	assert_that(g.next_scene_path).is_equal("res://scenes/levels/menus/menu.tscn")

func test_update_resources_goal_mapping() -> void:
	var g = load(GLOBALS_SCRIPT).new()
	var orig_day: int = StatsManager.day
	var orig_need: int = StatsManager.resources_needed
	var expected := {0: 50, 1: 100, 2: 200, 3: 0}
	for day in [0, 1, 2, 3]:
		StatsManager.day = day
		g.update_resources_goal()
		assert_that(StatsManager.resources_needed).is_equal(expected[day])
	StatsManager.day = orig_day
	StatsManager.resources_needed = orig_need

func test_setting_has_energy_in_spaceship_stores_fragment_sum() -> void:
	var g = load(GLOBALS_SCRIPT).new()
	var orig_need: int = StatsManager.resources_needed
	g.has_energy_in_spaceship = true
	assert_that(g.fragments_value_to_sum).is_equal(StatsManager.resources_needed)
	assert_that(g.has_energy_in_spaceship).is_false()
	StatsManager.resources_needed = orig_need

func test_add_frag_sum_increases_current_resources() -> void:
	var g = load(GLOBALS_SCRIPT).new()
	var orig_sum: int = g.fragments_value_to_sum
	var orig_resources: int = StatsManager.current_resources
	g.fragments_value_to_sum = 7
	g.add_frag_sum()
	assert_that(StatsManager.current_resources).is_equal(orig_resources + 7)
	StatsManager.current_resources = orig_resources
	g.fragments_value_to_sum = orig_sum
