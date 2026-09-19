class_name Monitor
extends ActionExecutor

var lights_on: bool = false

@onready var sprite_background: Sprite2D = $SpriteBackground

@onready var sprite_face: AnimatedSprite2D = $SpriteBackground/SpriteFace

@onready var control_power_up_ui: PowerUpUI = $CanvasLayer/ControlPowerUpUI


func start():
	current_state = States.BLOCKED

	pcam.set_priority(2000)

	#PopUpSystem.show_text(message, 2)
	await enable_screen()
	await start_ui()

	current_state = States.FREE


func finish():
	await kill_ui()
	await disable_screen()

	current_state = States.FREE

	pcam.set_priority(0)


func _ready() -> void:
	Globals.spaceship_energy = true

	add_to_group("PU_State_Listeners")
	SpaceshipEventBus.resource_count_finished.connect(_on_resource_count_finished)


func _on_resource_count_finished():
	turn_lights_on()


func enable_screen():
	HandsEventBus.monitor.emit(true)
	var new_face_alpha = 0.09

	await get_tree().create_timer(0.1).timeout

	var tween = create_tween()
	tween.tween_property(sprite_face, "modulate:a", new_face_alpha, 0.7)

	await tween.finished



func disable_screen():
	HandsEventBus.monitor.emit(false)
	var new_face_alpha = 0.00

	var tween = create_tween()
	tween.tween_property(sprite_face, "modulate:a", new_face_alpha, 0.7)


func start_ui():
	await get_tree().create_timer(0.1).timeout
	await control_power_up_ui.show_power_ups()


func kill_ui():
	await control_power_up_ui.hide_power_ups()


func update_pu_state() -> void:
	current_state = (
		States.BLOCKED
		if get_tree().get_first_node_in_group("Busy_PU_Button_Group")
		else States.FREE
	)


func turn_lights_on():
	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	tween.tween_property(sprite_background, "self_modulate", Color(8, 8, 8), 0.02)
	tween.tween_property(sprite_background, "self_modulate", Color(0.016, 0.016, 0.016, 1.0), 0.08)
