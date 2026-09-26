class_name DiaryPageController
extends Control

@export var animation_delay: float = 1.0

var current_day: int = 0
var is_open: bool = false
var is_navigating: bool = false

@onready var page_left: DiaryPage = $PagesContainer/PageL
@onready var page_right: DiaryPage = $PagesContainer/PageR
@onready var button_left: Button = $ButtonsContainer/ButtonL
@onready var button_right: Button = $ButtonsContainer/ButtonR


func _ready():
	button_left.pressed.connect(on_prev_pressed)
	button_right.pressed.connect(on_next_pressed)


func open_diary():
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

	_update_buttons()


# Helpers
func _get_max_spread() -> int:
	var max_day = StatsManager.day
	return int(floor(max_day / 2.0))


func _update_buttons():
	var max_day = StatsManager.day

	var is_left_disabled = current_day <= 0
	var is_right_disabled = current_day >= max_day

	button_left.disabled = is_left_disabled
	button_right.disabled = is_right_disabled

	button_left.modulate.a = 0.0 if is_left_disabled else 1.0
	button_right.modulate.a = 0.0 if is_right_disabled else 1.0


# Navigation
func on_next_pressed():
	if is_navigating or current_day >= StatsManager.day:
		return

	is_navigating = true
	current_day += 1
	HandsEventBus.page_next.emit()

	await get_tree().create_timer(animation_delay).timeout

	show_day()
	is_navigating = false


func on_prev_pressed():
	if is_navigating or current_day <= 0:
		return

	is_navigating = true
	current_day -= 1
	HandsEventBus.page_prev.emit()

	await get_tree().create_timer(animation_delay).timeout

	show_day()
	is_navigating = false


func _input(event: InputEvent) -> void:
	if not is_open or is_navigating:
		return

	if event.is_action_pressed("ui_right"):
		on_next_pressed()

	if event.is_action_pressed("ui_left"):
		on_prev_pressed()
