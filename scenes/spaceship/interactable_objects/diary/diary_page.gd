class_name DiaryPage
extends VBoxContainer

@export var head_text: String

@export var main_text: String

@export var sketch_texture: CompressedTexture2D

var base_day_text: String

@onready var day_label: RichTextLabel = $DayLabel

@onready var head_label: RichTextLabel = $HeadLabel

@onready var main_label: RichTextLabel = $MainLabel

@onready var sketch: TextureRect = $SketchTexture

func _ready():
	base_day_text = day_label.text

func setup_left(day: int, data: Dictionary):
	head_label.text = ""
	main_label.text = ""
	sketch.texture = null
	sketch.hide()

	day_label.text = base_day_text.replace("#", str(day))

	head_label.text = data.get("head", "")
	main_label.text = data.get("main", "")

	var tex = data.get("sketch", null)
	if tex:
		sketch.texture = tex
		sketch.show()

func setup_right(data: Dictionary):
	# NO DAY, NO HEAD
	day_label.text = ""
	head_label.text = ""
	main_label.text = ""
	sketch.texture = null
	sketch.hide()

	main_label.text = data.get("main", "")

	var tex = data.get("sketch", null)
	if tex:
		sketch.texture = tex
		sketch.show()
