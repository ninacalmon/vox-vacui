class_name Settings
extends Control

@export var inverse_visibility_nodes: Array[Node]

@onready var master_sound_slider_container: HBoxContainer = %MasterSoundSliderContainer

@onready var master_sound_slider: HSlider = master_sound_slider_container.get_node("HSlider")

@onready var main_music_slider_container: HBoxContainer = %MainMusicSliderContainer

@onready var main_music_slider: HSlider = main_music_slider_container.get_node("HSlider")

@onready var sound_effects_slider_container: HBoxContainer = %SoundEffectsSliderContainer

@onready var sound_effects_slider: HSlider = sound_effects_slider_container.get_node("HSlider")

@onready var back_button: Button = %BackButton

@onready var settings_container: Control = self

@onready var master_bus_idx = AudioServer.get_bus_index("Master")

@onready var music_bus_idx = AudioServer.get_bus_index("Music")

@onready var sound_effects_bus_idx = AudioServer.get_bus_index("Sound Effects")

func _ready():
	master_sound_slider.value = db_to_linear(AudioServer.get_bus_volume_db(self.master_bus_idx))
	main_music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(self.music_bus_idx))
	sound_effects_slider.value = db_to_linear(
			AudioServer.get_bus_volume_db(self.sound_effects_bus_idx)
		)

	self.master_sound_slider.value_changed.connect(_on_master_slider_changed)
	self.main_music_slider.value_changed.connect(_on_music_slider_changed)
	self.sound_effects_slider.value_changed.connect(_on_sound_effects_slider_changed)
	self.back_button.pressed.connect(_on_back_button_pressed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("return"):
		_on_back_button_pressed()

func my_grab_focus():
	master_sound_slider.grab_focus()

func _on_master_slider_changed(value: float):
	var db = linear_to_db(value)

	AudioServer.set_bus_volume_db(self.master_bus_idx, db)

func _on_music_slider_changed(value: float):
	var db = linear_to_db(value)

	AudioServer.set_bus_volume_db(self.music_bus_idx, db)

func _on_sound_effects_slider_changed(value: float):
	var db = linear_to_db(value)

	AudioServer.set_bus_volume_db(self.sound_effects_bus_idx, db)

func _on_back_button_pressed():
	self.settings_container.hide()

	for canvas_node in inverse_visibility_nodes:
		canvas_node.show()
		for c in canvas_node.get_children():
			if c is SettingsButton:
				c.grab_focus()
