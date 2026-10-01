extends Control

signal menu_selection_changed(selection_number: int)

@onready var start: Button = $Pressable/Start

@onready var controls: Button = $Pressable/Controls

@onready var exit: Button = $Pressable/Exit

@onready var controlers_overlay: ColorRect = $ControlersOverlay

@onready var settings: SettingsButton = $Pressable/Settings

@onready var control_exit_button: Button = $ControlersOverlay/ControlExitButton

@onready var _continue: Button = $Pressable/Continue

func _ready() -> void:
	Engine.time_scale = 1.0

	_continue.visible = StatsManager.day != 0
	#Globals.level = 1
	_continue.pressed.connect(_on_continue_pressed)
	start.pressed.connect(_on_start_button_pressed)
	controls.pressed.connect(_on_controls_button_pressed)
	exit.pressed.connect(_on_exit_button_pressed)
	control_exit_button.pressed.connect(_on_control_exit_pressed)

	_continue.focus_entered.connect(_on_button_hovered.bind(0))
	_continue.mouse_entered.connect(_on_button_hovered.bind(0))
	start.mouse_entered.connect(_on_button_hovered.bind(1))
	start.focus_entered.connect(_on_button_hovered.bind(1))
	settings.mouse_entered.connect(_on_button_hovered.bind(2))
	settings.focus_entered.connect(_on_button_hovered.bind(2))
	exit.mouse_entered.connect(_on_button_hovered.bind(3))
	exit.focus_entered.connect(_on_button_hovered.bind(3))

	Input.joy_connection_changed.connect(_on_joy_connected)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	InputGuide.clear_guides()

	if StatsManager.day != 0:
		_continue.grab_focus()
	else: start.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_continue_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Globals.add_frag_sum()
	LevelTransition.change_scene_to("res://scenes/levels/spaceship_interior/spaceship_interior.tscn")

func _on_start_button_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Globals.reset_game_state()
	StatsManager.reset_game_state()
	PowerUps.reset_game_state()
	LevelTransition.change_scene_to("res://scenes/levels/tutorial/Tutorial.tscn")

func _on_controls_button_pressed():
	controlers_overlay.show()
	control_exit_button.grab_focus()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_control_exit_pressed():
	controlers_overlay.hide()
	controls.grab_focus()

func _on_button_hovered(number: int) -> void:
	menu_selection_changed.emit(number)

func _on_joy_connected(_device: int, connected: bool):
	if connected:
		start.grab_focus()
