class_name Diary
extends MainArea

var has_energy: bool = false

@onready var sprite_mini_book: Sprite2D = $SpriteMiniBook

@onready var sprite_open: Sprite2D = $BookCanvasLayer/SpriteOpen

@onready var animation_take_book: AnimationPlayer = $SpriteMiniBook/AnimationTakeBook

@onready var animation_book_open: AnimationPlayer = $BookCanvasLayer/SpriteOpen/AnimationBookOpen

@onready var diary_control: DiaryPageController = $BookCanvasLayer/DiaryControl

@onready var blur_rect: ColorRect = $BookCanvasLayer/BlurRect

func _ready() -> void:
	#has_energy = true
	_connect_signals()
	_initialize_ui()

func slow_color_change(
	subject: Node, duration: float = 0.5, final_modulate: Color = Color(1, 1, 1, 0)
):
	var tween = create_tween()
	tween.tween_property(subject, "modulate", final_modulate, duration)
	await tween.finished

func _connect_signals():
	clickable_highlight.was_clicked.connect(_on_clicked)
	SpaceshipEventBus.focus_changed.connect(_on_focus_changed)
	SpaceshipEventBus.resource_count_finished.connect(_on_resource_count_finished)

func _initialize_ui():
	blur_rect.hide()
	diary_control.hide()
	sprite_open.hide()

# Animations vvvvvvvvvvvv
func _take_book():
	animation_take_book.play("take_book")
	await get_tree().create_timer(animation_take_book.current_animation_length * 0.9).timeout
	HandsEventBus.book.emit(true)
	_open_book()

func _open_book():
	diary_control.open_diary()
	_show_blur()
	await _play_open_animation()
	_show_book_ui()
	can_exit = true

func _close_book():
	if not is_focused:
		return

	await _hide_book_ui()
	await _play_close_animation()
	HandsEventBus.book.emit(false)
	_hide_blur()

	_return_book()

func _return_book():
	animation_take_book.play_backwards("take_book")

# Visual Steps vvvvvvvv
func _show_blur():
	blur_rect.modulate.a = 0
	blur_rect.show()
	slow_color_change(blur_rect, 0.5, Color(1, 1, 1, 1))

func _hide_blur():
	slow_color_change(blur_rect, 0.5)
	blur_rect.hide()

func _play_open_animation():
	sprite_open.show()
	animation_book_open.play("open_book")
	await get_tree().create_timer(animation_book_open.current_animation_length).timeout

func _play_close_animation():
	animation_book_open.play_backwards("open_book")
	await get_tree().create_timer(animation_book_open.current_animation_length).timeout
	sprite_open.hide()

func _show_book_ui():
	diary_control.modulate.a = 0
	diary_control.show()
	slow_color_change(diary_control, 0.2, Color(1, 1, 1, 1))

func _hide_book_ui():
	slow_color_change(diary_control, 0.2)
	await get_tree().create_timer(0.2).timeout
	diary_control.hide()

func _on_resource_count_finished():
	has_energy = true

func _on_clicked():
	if not has_energy or StatsManager.day == 3:
		HandsEventBus.not_yet.emit()
		if StatsManager.day != 3:
			PopUpSystem.show_text("Está muito escuro.")
		return

	if not is_focused and clickable_highlight.is_mouse_over_area:
		SpaceshipEventBus.focus_on.emit(zoom_in_amount, zoom_offset, self, true)

func _on_focus_changed(focus: bool, subject: Node2D):
	if focus and subject == self:
		is_focused = true
		can_exit = false
		_take_book()
	else:
		clickable_highlight.is_mouse_over_area = false
		clickable_highlight.active = true
		_close_book()
		is_focused = false
