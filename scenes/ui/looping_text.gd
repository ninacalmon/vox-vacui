extends HBoxContainer

var speed := 100.0

@onready var text1 = $LoopingText

@onready var text2 = $LoopingText2

@onready var text3 = $LoopingText3

func _process(delta):
	position.x -= speed * delta

	var width = get_combined_minimum_size().x / 3

	if position.x <= -width:
		position.x = 0
