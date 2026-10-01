extends Control

var original_text: String

@onready var day_label: RichTextLabel = $DayLabel

func _ready() -> void:
	original_text = day_label.text
	day_label.text = original_text.replace("#", str(StatsManager.day))
