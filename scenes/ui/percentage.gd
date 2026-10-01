extends RichTextLabel

@export var bar: TextureProgressBar

func _process(_delta):
	var t = (bar.value - bar.min_value) / (bar.max_value - bar.min_value)
	position.x = bar.size.x * t

	var percentage: int = int((bar.value / bar.max_value) * 100)
	text = "%d%%" %percentage
