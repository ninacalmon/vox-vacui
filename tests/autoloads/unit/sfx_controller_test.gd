extends GdUnitTestSuite

func test_play_sound_without_audio_player_returns_safely() -> void:
	SFXManager.play_sound(null)
	assert_that(true).is_true()

func test_queue_free_audio_player_with_invalid_reference_is_safe() -> void:
	var sm = load("res://autoloads/sfx_manager.gd").new()
	sm.queue_free_audio_player(null)
	assert_that(true).is_true()

func test_vibrate_controller_zero_index_is_safe() -> void:
	var cv = load("res://autoloads/controller_vibration.gd").new()
	cv.vibrate_controller(0, 0.05, 0)
	assert_that(true).is_true()
