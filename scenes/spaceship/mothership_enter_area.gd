class_name MotherShipEntrance
extends Area2D

@export var disable: bool = false

var door_sfx_pitch: float

var is_entering: bool

var is_showing_confirmation: bool = false

var player_onto_area: bool

@onready var door_sfx: AudioStreamPlayer = $DoorSFX

@onready var confirmation_canvas_layer: CanvasLayer = $"../ConfirmationCanvasLayer"

@onready var button_no: Button = $"../ConfirmationCanvasLayer/HBoxContainer/ButtonNo"

@onready var button_yes: Button = $"../ConfirmationCanvasLayer/HBoxContainer/ButtonYes"

func _ready() -> void:
	confirmation_canvas_layer.hide()
	door_sfx_pitch = door_sfx.pitch_scale
	Globals.changing_scene = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	button_yes.pressed.connect(_on_yes_pressed)
	button_no.pressed.connect(_on_no_pressed)
	button_yes.focus_entered.connect(_on_yes_focus_entered)
	button_no.focus_entered.connect(_on_no_focus_entered)

func _process(_delta: float) -> void:
	Globals.is_showing_confirmation = is_showing_confirmation

func _input(event: InputEvent) -> void:
	if Globals.is_cutscene or get_tree().paused:
		return
	if event.is_action_pressed("confirm") and player_onto_area:
		#get_viewport().set_input_as_handled()
		if StatsManager.current_resources < StatsManager.resources_needed:
			## feebback!!
			door_sfx.pitch_scale = 5
			SFXManager.play_sound(door_sfx)
			door_sfx.pitch_scale = door_sfx_pitch
			return
		if not is_entering and not is_showing_confirmation:
			get_viewport().set_input_as_handled()
			#get_tree().paused = true
			Engine.time_scale = 0.1
			confirmation_canvas_layer.show()
			is_showing_confirmation = true
			button_no.grab_focus()

func _on_body_entered(body: PhysicsBody2D):
	if not (body is Player):
		return
	if disable:
		return
	player_onto_area = true
	if StatsManager.current_resources < StatsManager.resources_needed:
		var resources_you_need: int = StatsManager.resources_needed - StatsManager.current_resources
		PopUpSystem.show_text("Colete [b]%d[/b] ou mais fragmentos para retornar à nave-mãe." %resources_you_need, 5)

## DAY 3 ===============================================
	if StatsManager.day == 3 and not StatsManager.player_has_cadaver:
		PopUpSystem.show_text("Traga o corpo d'A Matriarca.", 5)
## =====================================================
	EventBus.mothership_entrance_entered.emit()

func _on_body_exited(body: PhysicsBody2D):
	if body is Player:
		player_onto_area = false
		disable = false
		Engine.time_scale = 1
		confirmation_canvas_layer.hide()
		is_showing_confirmation = false
		EventBus.mothership_entrance_exited.emit()

func _on_yes_pressed():
	#get_tree().paused = false
	Engine.time_scale = 1
	is_entering = true
	EventBus.player_wants_to_enter_mothership.emit()
	Globals.changing_scene = true
	SFXManager.play_sound(door_sfx)
	is_showing_confirmation = false
	Globals.is_showing_confirmation = false
	LevelTransition.change_scene_to(
		"res://scenes/levels/spaceship_interior/spaceship_interior.tscn", 1.2
	)

func _on_no_pressed():
	#get_tree().paused = false
	Engine.time_scale = 1
	confirmation_canvas_layer.hide()
	is_showing_confirmation = false
	return

func _on_yes_focus_entered():
	button_no.text = button_no.text.remove_chars("*")
	if not button_yes.text.contains("*"):
		button_yes.text = button_yes.text.insert(0, "*")

func _on_no_focus_entered():
	button_yes.text = button_yes.text.remove_chars("*")
	if not button_no.text.contains("*"):
		button_no.text = button_no.text.insert(0, "*")
