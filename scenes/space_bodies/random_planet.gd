extends Sprite2D

@export var texture_options: Array[Texture]

@export var body_randomizer: BodyRandomizer

func _ready() -> void:
	if texture_options:
		texture = texture_options.pick_random()
