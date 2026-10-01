extends Control

@export var animation_delay: float = 1

var current_day: int = 3

@onready var page_left: DiaryPage = $PagesContainer/PageL

@onready var page_right: DiaryPage = $PagesContainer/PageR

@onready var animation_book_open: AnimationPlayer = $"../SpriteOpen/AnimationBookOpen"

@onready var cutscene_context: CutsceneControl = $".."

func _ready() -> void:
	Globals.next_scene_path = "res://scenes/cutscenes/cutscene_credits.tscn"
	hide()
	modulate = Color.TRANSPARENT
	animation_book_open.animation_finished.connect(open_diary)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		cutscene_context.finish_cutscene()

func open_diary(_anim):
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1)
	current_day = StatsManager.day
	show_day()

func show_day():
	var max_day = StatsManager.day
	var day_data = DiaryDatabase.get_day(current_day)

	# LEFT
	if current_day <= max_day:
		page_left.setup_left(current_day, day_data["left"])
	else:
		page_left.setup_left(0, DiaryDatabase.EMPTY_DAY["left"])

	# RIGHT
	if current_day <= max_day:
		page_right.setup_right(day_data["right"])
	else:
		page_right.setup_right(DiaryDatabase.EMPTY_DAY["right"])

# Helpers
func _get_max_spread() -> int:
	var max_day = StatsManager.day
	return int(floor(max_day / 2.0))
