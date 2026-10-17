extends Node2D


@onready var target_sprite: Sprite2D = $TargetSprite

func _ready() -> void:
	hide()
	target_sprite.show()
