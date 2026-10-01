class_name GameOverScene
extends Control

@export var background_texture: TextureRect

@export var sub_text: RichTextLabel

var cause_of_death: String

@onready var pressable: VBoxContainer = $CanvasLayer/Pressable

func _ready() -> void:
	InputGuide.clear_guides()
	PopUpSystem.clear()
