class_name SettingsButton
extends Button

@export var inverse_visibility_nodes: Array[Node]

@onready var settings_container: Settings = %SettingsContainer

func _ready():
	self.pressed.connect(_on_settings_button_pressed)

func _on_settings_button_pressed():
	self.settings_container.show()
	settings_container.my_grab_focus()
	for canvas_node in inverse_visibility_nodes:
		canvas_node.hide()
