extends GdUnitTestSuite

func _signal_names(node: Node) -> Array:
	var names: Array[String] = []
	for s in node.get_signal_list():
		names.append(s.name)
	return names

func test_event_bus_defines_core_signals() -> void:
	var names := _signal_names(EventBus)
	assert_that(names).contains("player_out_of_bounds")
	assert_that(names).contains("fuel_used")
	assert_that(names).contains("out_of_fuel")
	assert_that(names).contains("damage_taken")
	assert_that(names).contains("player_death")
	assert_that(names).contains("level_pass")
	assert_that(names).contains("cutscene_on")
	assert_that(names).contains("cutscene_off")
	assert_that(names).contains("vibrate")
	assert_that(names).contains("boss_in_capture_area")

func test_event_bus_emits_level_pass() -> void:
	var received := [false]
	var handler := func(): received[0] = true
	EventBus.level_pass.connect(handler)
	EventBus.level_pass.emit()
	assert_that(received[0]).is_true()
	EventBus.level_pass.disconnect(handler)

func test_event_bus_emits_damage_taken_with_args() -> void:
	var amount := [-1.0]
	var handler := func(damaged, dmg): amount[0] = dmg
	EventBus.damage_taken.connect(handler)
	EventBus.damage_taken.emit(null, 25.0)
	assert_that(amount[0]).is_equal(25.0)
	EventBus.damage_taken.disconnect(handler)

func test_spaceship_event_bus_defines_focus_signals() -> void:
	var names := _signal_names(SpaceshipEventBus)
	assert_that(names).contains("focus_on")
	assert_that(names).contains("focus_off")
	assert_that(names).contains("resource_count_finished")
	assert_that(names).contains("resource_count_started")
	assert_that(names).contains("resources_spent")
	assert_that(names).contains("player_going_out")

func test_spaceship_event_bus_emits_resource_count_finished() -> void:
	var received := [false]
	var handler := func(): received[0] = true
	SpaceshipEventBus.resource_count_finished.connect(handler)
	SpaceshipEventBus.resource_count_finished.emit()
	assert_that(received[0]).is_true()
	SpaceshipEventBus.resource_count_finished.disconnect(handler)

func test_hands_event_bus_defines_interaction_signals() -> void:
	var names := _signal_names(HandsEventBus)
	assert_that(names).contains("machine_interaction")
	assert_that(names).contains("monitor")
	assert_that(names).contains("book")
	assert_that(names).contains("page_prev")
	assert_that(names).contains("page_next")
	assert_that(names).contains("not_yet")

func test_hands_event_bus_starts_not_busy() -> void:
	assert_that(HandsEventBus.hand_is_busy).is_false()

func test_hands_event_bus_emits_monitor_state() -> void:
	var state := [false]
	var handler := func(value): state[0] = value
	HandsEventBus.monitor.connect(handler)
	HandsEventBus.monitor.emit(true)
	assert_that(state[0]).is_true()
	HandsEventBus.monitor.disconnect(handler)
