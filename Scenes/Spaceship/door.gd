extends MainArea

var has_energy: bool = false

var has_showed_text: bool = false

var is_showing_confirmation: bool = false

var has_clicked_yes: bool = false

@onready var door_sfx: AudioStreamPlayer = $DoorSFX

@onready var confirmation_canvas_layer: CanvasLayer = $ConfirmationCanvasLayer

@onready var button_no: Button = $ConfirmationCanvasLayer/HBoxContainer/ButtonNo

@onready var button_yes: Button = $ConfirmationCanvasLayer/HBoxContainer/ButtonYes

func _ready() -> void:
	confirmation_canvas_layer.hide()
	#has_energy = true
	_connect_signals()

func _process(_delta: float) -> void:
	if clickable_highlight.is_mouse_over_area and has_energy:
		if not has_showed_text:
			has_showed_text = true
			PopUpSystem.show_text("Sair da nave e iniciar um novo dia?", 3)
	else:
		has_showed_text = false

func show_confirm():
	if not is_showing_confirmation:
		get_viewport().set_input_as_handled()
		#get_tree().paused = true
		#Engine.time_scale = 0.1
		confirmation_canvas_layer.show()
		is_showing_confirmation = true
		button_no.grab_focus()

func go_out():
	SFXManager.play_sound(door_sfx)
	await get_tree().create_timer(1.2).timeout
	StatsManager.day += 1
	Globals.update_resources_goal()
	Globals.next_scene_path = get_next_level()
	LevelTransition.change_scene_to("res://scenes/cutscenes/cutscene_out_spaceship.tscn", 2)

func get_next_level() -> String:
	var scene_path: String = "res://scenes/levels/space_levels/Level_Day1.tscn"
	match StatsManager.day:
		#0: "res://scenes/levels/space_levels/LevelFinal2.tscn"
		1: scene_path = "res://scenes/levels/space_levels/Level_Day1.tscn"
		2: scene_path = "res://scenes/levels/space_levels/Level_Day2.tscn"
		3: scene_path = "res://scenes/levels/space_levels/Level_Day3.tscn"

	return scene_path

func _connect_signals():
	clickable_highlight.was_clicked.connect(_on_clicked)
	SpaceshipEventBus.focus_changed.connect(_on_focus_changed)
	SpaceshipEventBus.resource_count_finished.connect(_on_resource_count_finished)
	button_yes.pressed.connect(_on_yes_pressed)
	button_no.pressed.connect(_on_no_pressed)
	button_yes.focus_entered.connect(_on_yes_focus_entered)
	button_no.focus_entered.connect(_on_no_focus_entered)

func _on_resource_count_finished():
	has_energy = true

### CODIGO FEIAO vvvv
func _on_clicked():
	if not has_energy or StatsManager.day == 3:
		HandsEventBus.not_yet.emit()
		if StatsManager.day != 3:
			PopUpSystem.show_text("Sem energia.")
		return
	SpaceshipEventBus.focus_on.emit(zoom_in_amount, zoom_offset, self, true)

func _on_yes_pressed():
	if has_clicked_yes:
		return
	has_clicked_yes = true
	#get_tree().paused = false
	go_out()

func _on_no_pressed():
	#get_tree().paused = false
	confirmation_canvas_layer.hide()
	is_showing_confirmation = false
	SpaceshipEventBus.focus_off.emit()
	is_focused = false
	return

func _on_yes_focus_entered():
	button_no.text = button_no.text.remove_chars("*")
	if not button_yes.text.contains("*"):
		button_yes.text = button_yes.text.insert(0, "*")

func _on_no_focus_entered():
	button_yes.text = button_yes.text.remove_chars("*")
	if not button_no.text.contains("*"):
		button_no.text = button_no.text.insert(0, "*")

func _on_focus_changed(focus: bool, _subject: Node2D):
	## If there is a race condition with the activation of the clickable_highlight
	## here and the disabling of it on the ClickableHighlight module, we can work
	## around this problem having a state here that changes clickable_highlight.active
	## on process based off this state
	if focus == false:
		confirmation_canvas_layer.hide()
		clickable_highlight.is_mouse_over_area = false
		clickable_highlight.active = true
		is_focused = false
	elif focus and _subject == self:
		is_focused = true
		show_confirm()
