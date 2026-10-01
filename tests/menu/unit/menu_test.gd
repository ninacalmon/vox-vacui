extends GdUnitTestSuite

var menu_control: Control
var continue_button: Button
var start_button: Button
var settings_button: Button
var controls_button: Button
var exit_button: Button
var master_slider: HSlider
var music_slider: HSlider
var effects_slider: HSlider
var title_label: TextureRect
var canvas_layer: CanvasLayer

func before() -> void:
	var menu_scene := load("res://scenes/levels/menus/menu.tscn") as PackedScene
	menu_control = menu_scene.instantiate()
	add_child(menu_control)

	# Wait two frames so _ready() on menu_buttons_control.gd runs and
	# StatsManager.day != 0 evaluation settles.
	await get_tree().process_frame
	await get_tree().process_frame

	canvas_layer = menu_control.get_node_or_null("CanvasLayer") as CanvasLayer

	continue_button = menu_control.get_node_or_null("CanvasLayer/Control/Pressable/Continue") as Button
	start_button = menu_control.get_node_or_null("CanvasLayer/Control/Pressable/Start") as Button
	settings_button = menu_control.get_node_or_null("CanvasLayer/Control/Pressable/Settings") as Button
	controls_button = menu_control.get_node_or_null("CanvasLayer/Control/Pressable/Controls") as Button
	exit_button = menu_control.get_node_or_null("CanvasLayer/Control/Pressable/Exit") as Button

	master_slider = menu_control.get_node_or_null("CanvasLayer/Control/SettingsContainer/SettingsContainer/SettingsOptions/MasterSoundSliderContainer/HSlider") as HSlider
	music_slider = menu_control.get_node_or_null("CanvasLayer/Control/SettingsContainer/SettingsContainer/SettingsOptions/MainMusicSliderContainer/HSlider") as HSlider
	effects_slider = menu_control.get_node_or_null("CanvasLayer/Control/SettingsContainer/SettingsContainer/SettingsOptions/SoundEffectsSliderContainer/HSlider") as HSlider

	title_label = menu_control.get_node_or_null("CanvasLayer/Control/TitleLabel") as TextureRect

func after() -> void:
	if is_instance_valid(menu_control):
		menu_control.queue_free()

func test_buttons_exist():
	assert_that(continue_button).is_not_null()
	assert_that(start_button).is_not_null()
	assert_that(settings_button).is_not_null()
	assert_that(controls_button).is_not_null()
	assert_that(exit_button).is_not_null()

func test_buttons_are_visible():
	# Default visibility per scene: Continue is hidden when StatsManager.day == 0
	# (see menu_buttons_control.gd:17 _continue.visible = StatsManager.day != 0).
	# Controls is hidden because its overlay is closed (see scene line 322).
	# Start, Settings, Exit are visible by default in the main menu.
	assert_that(continue_button.visible).is_false()
	assert_that(start_button.visible).is_true()
	assert_that(settings_button.visible).is_true()
	assert_that(controls_button.visible).is_false()
	assert_that(exit_button.visible).is_true()

func test_settings_sliders_exist():
	assert_that(master_slider).is_not_null()
	assert_that(music_slider).is_not_null()
	assert_that(effects_slider).is_not_null()

func test_sliders_have_correct_ranges():
	assert_that(master_slider.min_value).is_less_equal(0.0)
	assert_that(master_slider.max_value).is_greater_equal(1.0)
	assert_that(music_slider.min_value).is_less_equal(0.0)
	assert_that(music_slider.max_value).is_greater_equal(1.0)
	assert_that(effects_slider.min_value).is_less_equal(0.0)
	assert_that(effects_slider.max_value).is_greater_equal(1.0)

func test_ui_sounds_nodes_exist():
	var ui_sounds = menu_control.get_node_or_null("UISounds")
	assert_that(ui_sounds).is_not_null()

	var hover_sfx = ui_sounds.get_node_or_null("HoverSFX")
	assert_that(hover_sfx).is_not_null()

	var click_sfx = ui_sounds.get_node_or_null("ClickSFX")
	assert_that(click_sfx).is_not_null()

func test_button_click_signals_connected():
	# menu_buttons_control.gd connects these methods in _ready() (lines 19-22) on the
	# Control node instance (CanvasLayer/Control). Verify via that node, not the script.
	var controls_node = menu_control.get_node_or_null("CanvasLayer/Control")
	assert_that(controls_node).is_not_null()

	assert_that(
		continue_button.pressed.is_connected(
			Callable(controls_node, "_on_continue_pressed")
		)
	).is_true()
	assert_that(
		start_button.pressed.is_connected(
			Callable(controls_node, "_on_start_button_pressed")
		)
	).is_true()
	assert_that(
		controls_button.pressed.is_connected(
			Callable(controls_node, "_on_controls_button_pressed")
		)
	).is_true()
	assert_that(
		exit_button.pressed.is_connected(
			Callable(controls_node, "_on_exit_button_pressed")
		)
	).is_true()
